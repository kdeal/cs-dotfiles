#!/usr/bin/env -S uv run --script
# /// script
# requires-python = ">=3.13"
# dependencies = []
# ///
"""Install extra commands that I might want.

Python port of `xdg_config/fish/functions/cmd_install.fish`.
"""

from __future__ import annotations

import argparse
import hashlib
import platform
import shutil
import subprocess
import sys
import tarfile
import tempfile
import tomllib
import urllib.error
import urllib.parse
import urllib.request
from dataclasses import dataclass
from pathlib import Path
from typing import Any, Literal

HOME = Path.home()
BIN_DIR = HOME / ".local" / "bin"
DEFAULT_CONFIG_PATH = Path(__file__).resolve().parents[1] / "cmd_install.toml"


@dataclass(frozen=True)
class ArchiveInstallSpec:
    name: str
    url: str
    sha256: str


@dataclass(frozen=True)
class SelectedArchSpec:
    context: str
    spec: dict[str, Any]


@dataclass(frozen=True)
class FileCopySpec:
    source: str
    destination: str
    mode: str


ARCH_ALIASES = {
    "amd64": "amd64",
    "x86_64": "amd64",
    "x64": "amd64",
    "arm64": "arm64",
    "aarch64": "arm64",
}

ALLOWED_SELECTED_ARCH_KEYS = {"arch", "variant", "sha256"}
ALLOWED_FILE_COPY_KEYS = {"source", "destination", "mode"}
COPY_MODES = {"file", "rsync-tree", "dircopy"}
unset = object()

DOWNLOAD_TIMEOUT_SECONDS = 30

ALLOWED_COMMAND_KEYS_BY_TYPE = {
    "archive_binary": {"type", "version", "url", "file_copies", "arch"},
    "archive_extract": {
        "type",
        "version",
        "url",
        "destination",
        "wrapper_path",
        "wrapper_exec",
        "arch",
    },
    "npm_global": {"type", "packages"},
    "uv_tool": {"type", "package", "post_install_pre_commit_hook"},
    "go_install": {"type", "package"},
    "rustup_component": {"type", "component"},
}

ValueType = Literal["table", "string", "boolean", "string_list", "copy_mode"]


class ConfigError(ValueError):
    pass


class InstallError(RuntimeError):
    pass


def normalize_arch(arch: str) -> str | None:
    return ARCH_ALIASES.get(arch.strip().lower())


def parse_arch(arch: str) -> str:
    normalized = normalize_arch(arch)
    if normalized is None:
        allowed = ", ".join(sorted(ARCH_ALIASES))
        raise argparse.ArgumentTypeError(f"Unsupported arch '{arch}'. Supported values: {allowed}")
    return normalized


def detect_default_arch() -> str:
    normalized = normalize_arch(platform.machine())
    if normalized is None:
        return "amd64"
    return normalized


def ensure_dirs() -> None:
    for path in (
        BIN_DIR,
        HOME / ".config" / "fish" / "completions",
        HOME / ".local" / "share" / "man" / "man1",
    ):
        path.mkdir(parents=True, exist_ok=True)


def command_exists(command: str) -> bool:
    return shutil.which(command) is not None


def run(cmd: list[str], *, check: bool = True) -> subprocess.CompletedProcess[str]:
    return subprocess.run(cmd, check=check, text=True)


def download_with_sha256(url: str, expected_sha256: str) -> Path:
    archive_name = Path(urllib.parse.urlparse(url).path).name
    suffix = "".join(Path(archive_name).suffixes)

    with tempfile.NamedTemporaryFile(delete=False, suffix=suffix) as handle:
        tmp_path = Path(handle.name)

    try:
        with (
            urllib.request.urlopen(url, timeout=DOWNLOAD_TIMEOUT_SECONDS) as response,
            tmp_path.open("wb") as out,
        ):
            shutil.copyfileobj(response, out)

        sha256 = hashlib.sha256()
        with tmp_path.open("rb") as downloaded:
            for chunk in iter(lambda: downloaded.read(1024 * 1024), b""):
                sha256.update(chunk)
        digest = sha256.hexdigest()
    except (OSError, urllib.error.URLError, ValueError) as exc:
        tmp_path.unlink(missing_ok=True)
        raise InstallError(f"Failed to download {url}: {exc}") from exc

    if digest != expected_sha256:
        tmp_path.unlink(missing_ok=True)
        raise InstallError(f"SHA256 mismatch for {url}: expected {expected_sha256}, got {digest}")

    return tmp_path


def extract_tar(archive: Path, destination: Path) -> None:
    suffixes = tuple(archive.suffixes)

    match suffixes:
        case (*_, ".tar", ".gz") | (*_, ".tgz"):
            mode = "r:gz"
        case (*_, ".tar", ".bz2") | (*_, ".tbz2"):
            mode = "r:bz2"
        case (*_, ".tar", ".xz") | (*_, ".txz"):
            mode = "r:xz"
        case (*_, ".tar"):
            mode = "r:"
        case _:
            raise ValueError(f"Unsupported tar archive extension for {archive.name}")

    with tarfile.open(archive, mode=mode) as tar:
        tar.extractall(destination, filter="data")


def copy_file(source: Path, destination: Path) -> None:
    destination.parent.mkdir(parents=True, exist_ok=True)
    shutil.copy2(source, destination)


def remove_path(path: Path) -> None:
    if path.is_dir() and not path.is_symlink():
        shutil.rmtree(path)
        return
    path.unlink()


def replace_directory_contents(source: Path, destination: Path) -> None:
    destination.mkdir(parents=True, exist_ok=True)
    for existing in destination.iterdir():
        remove_path(existing)
    for item in source.iterdir():
        copy_any(item, destination / item.name)


def validate_allowed_keys(mapping: dict[str, Any], allowed_keys: set[str], context: str) -> None:
    unexpected = sorted(set(mapping) - allowed_keys)
    if unexpected:
        keys = ", ".join(unexpected)
        raise ConfigError(f"{context} has unsupported keys: {keys}")


def parse(
    mapping: Any,
    key: str,
    context: str,
    value_type: ValueType,
    *,
    default: Any = unset,
) -> Any:
    required = default is unset

    if key == "":
        value = mapping
        value_context = context
    else:
        mapping_context = context or "value"
        if not isinstance(mapping, dict):
            raise ConfigError(f"{mapping_context} must be a table")
        value_context = f"{context}.{key}" if context else key
        if key not in mapping:
            if required:
                raise ConfigError(f"{value_context} is required")
            return default
        value = mapping[key]

    if value_type == "table":
        if not isinstance(value, dict):
            raise ConfigError(f"{value_context} must be a table")
        return value
    if value_type == "string":
        if not isinstance(value, str):
            raise ConfigError(f"{value_context} must be a string")
        return value
    if value_type == "boolean":
        if not isinstance(value, bool):
            raise ConfigError(f"{value_context} must be a boolean")
        return value
    if value_type == "string_list":
        if not isinstance(value, list) or not all(isinstance(item, str) for item in value):
            raise ConfigError(f"{value_context} must be a list of strings")
        return value
    if value_type == "copy_mode":
        if not isinstance(value, str):
            raise ConfigError(f"{value_context} must be a string")
        if value not in COPY_MODES:
            allowed_values = ", ".join(sorted(COPY_MODES))
            raise ConfigError(f"{value_context} must be one of: {allowed_values}")
        return value

    raise ConfigError(f"Unsupported value type '{value_type}'")


def render_template(value: str, variables: dict[str, Any], context: str) -> str:
    try:
        return value.format_map(variables)
    except KeyError as exc:
        missing = exc.args[0]
        raise ConfigError(f"{context} references unknown placeholder '{missing}'") from exc
    except ValueError as exc:
        raise ConfigError(f"{context} has invalid template syntax: {exc}") from exc


def parse_file_copies(
    value: Any,
    context: str,
    variables: dict[str, Any],
) -> list[FileCopySpec]:
    if not isinstance(value, list):
        raise ConfigError(f"{context} must be an array of tables")

    copies: list[FileCopySpec] = []
    for index, item in enumerate(value):
        item_context = f"{context}[{index}]"
        item_mapping = parse(item, "", item_context, "table")
        source = render_template(
            parse(item_mapping, "source", item_context, "string"),
            variables,
            f"{item_context}.source",
        )
        destination = render_template(
            parse(item_mapping, "destination", item_context, "string"),
            variables,
            f"{item_context}.destination",
        )
        mode = parse(item_mapping, "mode", item_context, "copy_mode", default="file")
        copies.append(FileCopySpec(source=source, destination=destination, mode=mode))
    return copies


def validate_file_copies_shape(value: Any, context: str) -> None:
    if not isinstance(value, list):
        raise ConfigError(f"{context} must be an array of tables")
    for index, item in enumerate(value):
        item_context = f"{context}[{index}]"
        item_mapping = parse(item, "", item_context, "table")
        validate_allowed_keys(item_mapping, ALLOWED_FILE_COPY_KEYS, item_context)
        parse(item_mapping, "source", item_context, "string")
        parse(item_mapping, "destination", item_context, "string")
        if "mode" in item_mapping:
            parse(item_mapping, "mode", item_context, "copy_mode")


def parse_selected_arch_spec(
    value: Any,
    context: str,
) -> dict[str, Any]:
    spec = parse(value, "", context, "table")
    validate_allowed_keys(spec, ALLOWED_SELECTED_ARCH_KEYS, context)

    entry_arch = parse(spec, "arch", context, "string")
    if normalize_arch(entry_arch) is None:
        raise ConfigError(f"{context}.arch has unsupported value '{entry_arch}'")

    parse(spec, "sha256", context, "string")
    if "variant" in spec:
        parse(spec, "variant", context, "string")

    return spec


def select_arch_spec(
    command: str, command_cfg: dict[str, Any], arch: str
) -> SelectedArchSpec | None:
    arch_context = f"commands.{command}.arch"
    arch_cfg = command_cfg.get("arch")
    if isinstance(arch_cfg, list):
        for index, entry in enumerate(arch_cfg):
            entry_context = f"{arch_context}[{index}]"
            entry_mapping = parse(entry, "", entry_context, "table")
            entry_arch = parse(entry_mapping, "arch", entry_context, "string")
            normalized = normalize_arch(entry_arch)
            if normalized is None:
                raise ConfigError(f"{entry_context}.arch has unsupported value '{entry_arch}'")
            if normalized == arch:
                return SelectedArchSpec(
                    context=entry_context,
                    spec=parse_selected_arch_spec(entry_mapping, entry_context),
                )
        return None

    raise ConfigError(f"{arch_context} must be an array of tables")


def collect_template_vars(
    command_cfg: dict[str, Any],
    selected_arch_spec: SelectedArchSpec,
    target_arch: str,
) -> dict[str, Any]:
    variables: dict[str, Any] = {"target_arch": target_arch, "arch": target_arch}
    for key, value in command_cfg.items():
        if isinstance(value, str | int | float | bool):
            variables[key] = value
    for key in ("arch", "variant", "sha256"):
        value = selected_arch_spec.spec.get(key)
        if isinstance(value, str | int | float | bool):
            variables[key] = value
    return variables


def resolve_string_value(
    command_cfg: dict[str, Any],
    key: str,
    command_context: str,
    variables: dict[str, Any],
) -> str:
    if key in command_cfg:
        value = parse(command_cfg, key, command_context, "string")
        return render_template(value, variables, f"{command_context}.{key}")
    raise ConfigError(f"{command_context}.{key} is required")


def resolve_optional_string_value(
    command_cfg: dict[str, Any],
    key: str,
    command_context: str,
    variables: dict[str, Any],
) -> str | None:
    if key in command_cfg:
        value = parse(command_cfg, key, command_context, "string")
        return render_template(value, variables, f"{command_context}.{key}")
    return None


def resolve_selected_arch_string_value(
    selected_arch_spec: SelectedArchSpec,
    key: str,
    variables: dict[str, Any],
) -> str:
    value = parse(selected_arch_spec.spec, key, selected_arch_spec.context, "string")
    return render_template(value, variables, f"{selected_arch_spec.context}.{key}")


def copy_any(source: Path, destination: Path) -> None:
    if source.is_dir():
        destination.parent.mkdir(parents=True, exist_ok=True)
        shutil.copytree(source, destination, dirs_exist_ok=True)
        return
    copy_file(source, destination)


def apply_file_copies(extract_root: Path, file_copies: list[FileCopySpec]) -> None:
    for file_copy in file_copies:
        source_path = extract_root / file_copy.source
        destination_path = HOME / file_copy.destination

        if file_copy.mode == "file":
            copy_file(source_path, destination_path)
            continue

        if file_copy.mode == "rsync-tree":
            run(["rsync", "-a", str(source_path) + "/", str(destination_path) + "/"])
            continue

        if file_copy.mode == "dircopy":
            for item in source_path.iterdir():
                copy_any(item, destination_path / item.name)
            continue

        raise ConfigError(f"Unsupported file copy mode '{file_copy.mode}'")


def install_archive_binary(command: str, command_cfg: dict[str, Any], arch: str) -> bool:
    selected_spec = select_arch_spec(command, command_cfg, arch)
    if selected_spec is None:
        print(f"{arch} is not yet supported for {command}", file=sys.stderr)
        return False

    command_context = f"commands.{command}"
    variables = collect_template_vars(command_cfg, selected_spec, arch)

    url = resolve_string_value(command_cfg, "url", command_context, variables)
    sha256 = resolve_selected_arch_string_value(selected_spec, "sha256", variables)
    file_copies = parse_file_copies(
        command_cfg["file_copies"], f"{command_context}.file_copies", variables
    )

    archive_spec = ArchiveInstallSpec(name=command, url=url, sha256=sha256)
    try:
        tmp_file = download_with_sha256(archive_spec.url, archive_spec.sha256)
    except InstallError as exc:
        print(f"Failed to install {archive_spec.name}: {exc}", file=sys.stderr)
        return False

    try:
        with tempfile.TemporaryDirectory() as extract_dir:
            extract_root = Path(extract_dir)
            extract_tar(tmp_file, extract_root)
            apply_file_copies(extract_root, file_copies)
    except (
        FileNotFoundError,
        OSError,
        tarfile.TarError,
        ValueError,
        subprocess.CalledProcessError,
    ) as exc:
        print(f"Failed to install {archive_spec.name}: {exc}", file=sys.stderr)
        return False
    finally:
        tmp_file.unlink(missing_ok=True)

    return True


def install_archive_extract(command: str, command_cfg: dict[str, Any], arch: str) -> bool:
    selected_spec = select_arch_spec(command, command_cfg, arch)
    if selected_spec is None:
        print(f"{arch} is not yet supported for {command}", file=sys.stderr)
        return False

    command_context = f"commands.{command}"
    variables = collect_template_vars(command_cfg, selected_spec, arch)
    url = resolve_string_value(command_cfg, "url", command_context, variables)
    sha256 = resolve_selected_arch_string_value(selected_spec, "sha256", variables)
    destination = resolve_string_value(
        command_cfg,
        "destination",
        command_context,
        variables,
    )
    wrapper_path = resolve_optional_string_value(
        command_cfg,
        "wrapper_path",
        command_context,
        variables,
    )
    wrapper_exec = resolve_optional_string_value(
        command_cfg,
        "wrapper_exec",
        command_context,
        variables,
    )

    archive_spec = ArchiveInstallSpec(name=command, url=url, sha256=sha256)
    try:
        tmp_file = download_with_sha256(archive_spec.url, archive_spec.sha256)
    except InstallError as exc:
        print(f"Failed to install {archive_spec.name}: {exc}", file=sys.stderr)
        return False

    try:
        with tempfile.TemporaryDirectory() as extract_dir:
            extract_root = Path(extract_dir)
            extract_tar(tmp_file, extract_root)

            destination_path = HOME / destination
            replace_directory_contents(extract_root, destination_path)

        if (wrapper_path is None) != (wrapper_exec is None):
            raise ConfigError(f"{command_context} must set both wrapper_path and wrapper_exec")
        if wrapper_path is not None and wrapper_exec is not None:
            wrapper = HOME / wrapper_path
            wrapper.parent.mkdir(parents=True, exist_ok=True)
            wrapper.write_text(
                f'#!/usr/bin/env sh\nexec "$HOME/{wrapper_exec}" "$@"\n',
                encoding="utf-8",
            )
            wrapper.chmod(0o755)
    except (OSError, tarfile.TarError, ValueError, ConfigError) as exc:
        print(f"Failed to install {archive_spec.name}: {exc}", file=sys.stderr)
        return False
    finally:
        tmp_file.unlink(missing_ok=True)

    return True


def install_npm_global(command: str, command_cfg: dict[str, Any]) -> bool:
    if not command_exists("npm"):
        print(f"npm unavailable can't install {command}", file=sys.stderr)
        return False

    packages = parse(command_cfg, "packages", f"commands.{command}", "string_list")
    run(["npm", "install", "-g", *packages])
    return True


def install_uv_tool(command: str, command_cfg: dict[str, Any]) -> bool:
    if not command_exists("uv"):
        print(f"uv unavailable can't install {command}", file=sys.stderr)
        return False

    package = parse(command_cfg, "package", f"commands.{command}", "string")
    run(["uv", "tool", "install", package])

    install_hook = parse(
        command_cfg,
        "post_install_pre_commit_hook",
        f"commands.{command}",
        "boolean",
        default=False,
    )
    if (
        install_hook
        and (run(["git", "rev-parse"], check=False).returncode == 0)
        and command_exists("pre-commit")
    ):
        run(["pre-commit", "install"], check=False)
    return True


def install_go_package(command: str, command_cfg: dict[str, Any]) -> bool:
    if not command_exists("go"):
        print(f"Go unavailable can't install {command}", file=sys.stderr)
        return False

    package = parse(command_cfg, "package", f"commands.{command}", "string")
    run(["go", "install", package])
    return True


def install_rustup_component(command: str, command_cfg: dict[str, Any]) -> bool:
    if not command_exists("rustup"):
        print(f"ERROR: rustup unavailable can't install {command}", file=sys.stderr)
        return False

    component = parse(command_cfg, "component", f"commands.{command}", "string")
    run(["rustup", "component", "add", component])
    return True


def enumerate_arch_specs(command: str, command_cfg: dict[str, Any]) -> list[SelectedArchSpec]:
    arch_context = f"commands.{command}.arch"
    arch_cfg = command_cfg.get("arch")

    if isinstance(arch_cfg, list):
        entries = []
        seen_arches: set[str] = set()
        for index, raw_entry in enumerate(arch_cfg):
            entry_context = f"{arch_context}[{index}]"
            entry = parse_selected_arch_spec(raw_entry, entry_context)
            normalized_arch = normalize_arch(entry["arch"])
            assert normalized_arch is not None
            if normalized_arch in seen_arches:
                raise ConfigError(f"{entry_context}.arch duplicates architecture '{entry['arch']}'")
            seen_arches.add(normalized_arch)
            entries.append(SelectedArchSpec(context=entry_context, spec=entry))
        return entries

    raise ConfigError(f"{arch_context} must be an array of tables")


def validate_type_specific(command: str, command_cfg: dict[str, Any]) -> None:
    command_type = parse(command_cfg, "type", f"commands.{command}", "string")
    allowed_keys = ALLOWED_COMMAND_KEYS_BY_TYPE.get(command_type)
    if allowed_keys is None:
        raise ConfigError(f"Unsupported command type '{command_type}' for commands.{command}")
    validate_allowed_keys(command_cfg, allowed_keys, f"commands.{command}")

    if command_type in {
        "archive_binary",
        "archive_extract",
    }:
        enumerate_arch_specs(command, command_cfg)
        parse(command_cfg, "url", f"commands.{command}", "string")

    if command_type == "archive_binary":
        if "file_copies" not in command_cfg:
            raise ConfigError(f"commands.{command}.file_copies is required")
        validate_file_copies_shape(command_cfg["file_copies"], f"commands.{command}.file_copies")
    elif command_type == "archive_extract":
        parse(command_cfg, "destination", f"commands.{command}", "string")
        wrapper_path = parse(
            command_cfg,
            "wrapper_path",
            f"commands.{command}",
            "string",
            default=None,
        )
        wrapper_exec = parse(
            command_cfg,
            "wrapper_exec",
            f"commands.{command}",
            "string",
            default=None,
        )
        if (wrapper_path is None) != (wrapper_exec is None):
            raise ConfigError(f"commands.{command} must set both wrapper_path and wrapper_exec")
    elif command_type == "npm_global":
        parse(command_cfg, "packages", f"commands.{command}", "string_list")
    elif command_type == "uv_tool":
        parse(command_cfg, "package", f"commands.{command}", "string")
        if "post_install_pre_commit_hook" in command_cfg:
            parse(command_cfg, "post_install_pre_commit_hook", f"commands.{command}", "boolean")
    elif command_type == "go_install":
        parse(command_cfg, "package", f"commands.{command}", "string")
    elif command_type == "rustup_component":
        parse(command_cfg, "component", f"commands.{command}", "string")


def load_config(path: Path) -> dict[str, dict[str, Any]]:
    try:
        raw = path.read_bytes()
    except OSError as exc:
        raise ConfigError(f"Unable to read config at {path}: {exc}") from exc

    try:
        parsed = tomllib.loads(raw.decode("utf-8"))
    except (tomllib.TOMLDecodeError, UnicodeDecodeError) as exc:
        raise ConfigError(f"Unable to parse TOML config at {path}: {exc}") from exc

    root = parse(parsed, "", "root", "table")
    commands_raw = parse(root, "commands", "root", "table")

    commands: dict[str, dict[str, Any]] = {}
    for name, cfg in commands_raw.items():
        command_name = parse(name, "", "command name", "string")
        command_cfg = parse(cfg, "", f"commands.{command_name}", "table")
        validate_type_specific(command_name, command_cfg)
        commands[command_name] = command_cfg

    if not commands:
        raise ConfigError("root.commands must define at least one command")
    return commands


def install_command(command: str, command_cfg: dict[str, Any], arch: str) -> bool:
    command_type = parse(command_cfg, "type", f"commands.{command}", "string")

    if command_type == "archive_binary":
        return install_archive_binary(command, command_cfg, arch)
    if command_type == "archive_extract":
        return install_archive_extract(command, command_cfg, arch)
    if command_type == "npm_global":
        return install_npm_global(command, command_cfg)
    if command_type == "uv_tool":
        return install_uv_tool(command, command_cfg)
    if command_type == "go_install":
        return install_go_package(command, command_cfg)
    if command_type == "rustup_component":
        return install_rustup_component(command, command_cfg)

    print(f"Unsupported command type '{command_type}' for {command}", file=sys.stderr)
    return False


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("commands", nargs="+", help="Command names to install")
    parser.add_argument(
        "--arch",
        type=parse_arch,
        default=detect_default_arch(),
        help="Target architecture (amd64/x86_64/x64 or arm64/aarch64)",
    )
    parser.add_argument(
        "--config",
        type=Path,
        default=DEFAULT_CONFIG_PATH,
        help=f"TOML config path (default: {DEFAULT_CONFIG_PATH})",
    )
    return parser.parse_args()


def main() -> int:
    args = parse_args()

    try:
        commands_cfg = load_config(args.config)
    except ConfigError as exc:
        print(f"Config error: {exc}", file=sys.stderr)
        return 1

    ensure_dirs()
    had_errors = False
    for cmd in args.commands:
        cfg = commands_cfg.get(cmd)
        if cfg is None:
            had_errors = True
            print(f'Command not recognized: "{cmd}"', file=sys.stderr)
            continue

        try:
            if not install_command(cmd, cfg, args.arch):
                had_errors = True
        except (subprocess.CalledProcessError, OSError, tarfile.TarError, ValueError) as exc:
            had_errors = True
            print(f"Failed to install {cmd}: {exc}", file=sys.stderr)

    return 1 if had_errors else 0


if __name__ == "__main__":
    raise SystemExit(main())
