#!/usr/bin/env -S uv run --script
# /// script
# requires-python = ">=3.14"
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
import urllib.request
from dataclasses import dataclass
from pathlib import Path
from typing import Any

HOME = Path.home()
CACHE_DIR = HOME / ".cache"
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


class ConfigError(ValueError):
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
        CACHE_DIR,
        BIN_DIR,
        HOME / ".config" / "fish" / "completions",
        HOME / ".local" / "share" / "man" / "man1",
    ):
        path.mkdir(parents=True, exist_ok=True)


def command_exists(command: str) -> bool:
    return shutil.which(command) is not None


def run(cmd: list[str], *, check: bool = True) -> subprocess.CompletedProcess[str]:
    return subprocess.run(cmd, check=check, text=True)


def download_with_sha256(url: str, expected_sha256: str) -> Path | None:
    with tempfile.NamedTemporaryFile(delete=False) as handle:
        tmp_path = Path(handle.name)

    with urllib.request.urlopen(url) as response, tmp_path.open("wb") as out:
        shutil.copyfileobj(response, out)

    sha256 = hashlib.sha256()
    with tmp_path.open("rb") as downloaded:
        for chunk in iter(lambda: downloaded.read(1024 * 1024), b""):
            sha256.update(chunk)
    digest = sha256.hexdigest()
    if digest != expected_sha256:
        tmp_path.unlink(missing_ok=True)
        return None
    return tmp_path


def extract_tar_gz(archive: Path, destination: Path) -> None:
    with tarfile.open(archive, mode="r:gz") as tar:
        tar.extractall(destination, filter="data")


def copy_file(source: Path, destination: Path) -> None:
    destination.parent.mkdir(parents=True, exist_ok=True)
    shutil.copy2(source, destination)


def parse_mapping(value: Any, context: str) -> dict[str, Any]:
    if not isinstance(value, dict):
        raise ConfigError(f"{context} must be a table")
    return value


def parse_string(value: Any, context: str) -> str:
    if not isinstance(value, str):
        raise ConfigError(f"{context} must be a string")
    return value


def parse_bool(value: Any, context: str) -> bool:
    if not isinstance(value, bool):
        raise ConfigError(f"{context} must be a boolean")
    return value


def parse_string_list(value: Any, context: str) -> list[str]:
    if not isinstance(value, list) or not all(isinstance(item, str) for item in value):
        raise ConfigError(f"{context} must be a list of strings")
    return value


def parse_copy_mode(value: Any, context: str) -> str:
    mode = parse_string(value, context)
    allowed = {"file", "rsync-tree", "dircopy"}
    if mode not in allowed:
        allowed_values = ", ".join(sorted(allowed))
        raise ConfigError(f"{context} must be one of: {allowed_values}")
    return mode


def require_string(mapping: dict[str, Any], key: str, context: str) -> str:
    if key not in mapping:
        raise ConfigError(f"{context}.{key} is required")
    return parse_string(mapping[key], f"{context}.{key}")


def require_mapping(mapping: dict[str, Any], key: str, context: str) -> dict[str, Any]:
    if key not in mapping:
        raise ConfigError(f"{context}.{key} is required")
    return parse_mapping(mapping[key], f"{context}.{key}")


def require_string_list(mapping: dict[str, Any], key: str, context: str) -> list[str]:
    if key not in mapping:
        raise ConfigError(f"{context}.{key} is required")
    return parse_string_list(mapping[key], f"{context}.{key}")


def get_optional_string(mapping: dict[str, Any], key: str, context: str) -> str | None:
    value = mapping.get(key)
    if value is None:
        return None
    return parse_string(value, f"{context}.{key}")


def get_optional_bool(mapping: dict[str, Any], key: str, context: str, *, default: bool) -> bool:
    value = mapping.get(key)
    if value is None:
        return default
    return parse_bool(value, f"{context}.{key}")


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
        item_mapping = parse_mapping(item, item_context)
        source = render_template(
            require_string(item_mapping, "source", item_context),
            variables,
            f"{item_context}.source",
        )
        destination = render_template(
            require_string(item_mapping, "destination", item_context),
            variables,
            f"{item_context}.destination",
        )
        mode = parse_copy_mode(item_mapping.get("mode", "file"), f"{item_context}.mode")
        copies.append(FileCopySpec(source=source, destination=destination, mode=mode))
    return copies


def validate_file_copies_shape(value: Any, context: str) -> None:
    if not isinstance(value, list):
        raise ConfigError(f"{context} must be an array of tables")
    for index, item in enumerate(value):
        item_context = f"{context}[{index}]"
        item_mapping = parse_mapping(item, item_context)
        require_string(item_mapping, "source", item_context)
        require_string(item_mapping, "destination", item_context)
        if "mode" in item_mapping:
            parse_copy_mode(item_mapping["mode"], f"{item_context}.mode")


def select_arch_spec(
    command: str, command_cfg: dict[str, Any], arch: str
) -> SelectedArchSpec | None:
    arch_context = f"commands.{command}.arch"
    arch_cfg = command_cfg.get("arch")
    if isinstance(arch_cfg, dict):
        raw_spec = arch_cfg.get(arch)
        if raw_spec is None:
            return None
        return SelectedArchSpec(
            context=f"{arch_context}.{arch}",
            spec=parse_mapping(raw_spec, f"{arch_context}.{arch}"),
        )

    if isinstance(arch_cfg, list):
        for index, entry in enumerate(arch_cfg):
            entry_context = f"{arch_context}[{index}]"
            entry_mapping = parse_mapping(entry, entry_context)
            entry_arch = require_string(entry_mapping, "arch", entry_context)
            normalized = normalize_arch(entry_arch)
            if normalized is None:
                raise ConfigError(f"{entry_context}.arch has unsupported value '{entry_arch}'")
            if normalized == arch:
                return SelectedArchSpec(context=entry_context, spec=entry_mapping)
        return None

    raise ConfigError(f"{arch_context} must be a table or an array of tables")


def collect_template_vars(
    command_cfg: dict[str, Any],
    selected_arch_spec: SelectedArchSpec,
    target_arch: str,
) -> dict[str, Any]:
    variables: dict[str, Any] = {"target_arch": target_arch}
    for key, value in command_cfg.items():
        if isinstance(value, str | int | float | bool):
            variables[key] = value
    for key, value in selected_arch_spec.spec.items():
        if isinstance(value, str | int | float | bool):
            variables[key] = value
    return variables


def resolve_string_value(
    command_cfg: dict[str, Any],
    selected_arch_spec: SelectedArchSpec,
    key: str,
    command_context: str,
    variables: dict[str, Any],
) -> str:
    if key in selected_arch_spec.spec:
        value = parse_string(selected_arch_spec.spec[key], f"{selected_arch_spec.context}.{key}")
        return render_template(value, variables, f"{selected_arch_spec.context}.{key}")
    if key in command_cfg:
        value = parse_string(command_cfg[key], f"{command_context}.{key}")
        return render_template(value, variables, f"{command_context}.{key}")
    raise ConfigError(f"{command_context}.{key} is required")


def resolve_optional_string_value(
    command_cfg: dict[str, Any],
    selected_arch_spec: SelectedArchSpec,
    key: str,
    command_context: str,
    variables: dict[str, Any],
) -> str | None:
    if key in selected_arch_spec.spec:
        value = parse_string(selected_arch_spec.spec[key], f"{selected_arch_spec.context}.{key}")
        return render_template(value, variables, f"{selected_arch_spec.context}.{key}")
    if key in command_cfg:
        value = parse_string(command_cfg[key], f"{command_context}.{key}")
        return render_template(value, variables, f"{command_context}.{key}")
    return None


def resolve_file_copies(
    command_cfg: dict[str, Any],
    selected_arch_spec: SelectedArchSpec,
    command_context: str,
    variables: dict[str, Any],
) -> list[FileCopySpec]:
    if "file_copies" in selected_arch_spec.spec:
        return parse_file_copies(
            selected_arch_spec.spec["file_copies"],
            f"{selected_arch_spec.context}.file_copies",
            variables,
        )
    if "file_copies" in command_cfg:
        return parse_file_copies(
            command_cfg["file_copies"],
            f"{command_context}.file_copies",
            variables,
        )
    raise ConfigError(f"{command_context}.file_copies is required")


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

    url = resolve_string_value(command_cfg, selected_spec, "url", command_context, variables)
    sha256 = resolve_string_value(command_cfg, selected_spec, "sha256", command_context, variables)
    file_copies = resolve_file_copies(command_cfg, selected_spec, command_context, variables)

    archive_spec = ArchiveInstallSpec(name=command, url=url, sha256=sha256)
    tmp_file = download_with_sha256(archive_spec.url, archive_spec.sha256)
    if tmp_file is None:
        print(f"Hashes don't match expected for {archive_spec.name}", file=sys.stderr)
        return False

    try:
        with tempfile.TemporaryDirectory(dir=CACHE_DIR) as extract_dir:
            extract_root = Path(extract_dir)
            extract_tar_gz(tmp_file, extract_root)
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
    url = resolve_string_value(command_cfg, selected_spec, "url", command_context, variables)
    sha256 = resolve_string_value(command_cfg, selected_spec, "sha256", command_context, variables)
    destination = resolve_string_value(
        command_cfg,
        selected_spec,
        "destination",
        command_context,
        variables,
    )
    wrapper_path = resolve_optional_string_value(
        command_cfg,
        selected_spec,
        "wrapper_path",
        command_context,
        variables,
    )
    wrapper_exec = resolve_optional_string_value(
        command_cfg,
        selected_spec,
        "wrapper_exec",
        command_context,
        variables,
    )

    archive_spec = ArchiveInstallSpec(name=command, url=url, sha256=sha256)
    tmp_file = download_with_sha256(archive_spec.url, archive_spec.sha256)
    if tmp_file is None:
        print(f"Hashes don't match expected for {archive_spec.name}", file=sys.stderr)
        return False

    try:
        destination_path = HOME / destination
        destination_path.mkdir(parents=True, exist_ok=True)
        extract_tar_gz(tmp_file, destination_path)

        if (wrapper_path is None) != (wrapper_exec is None):
            raise ConfigError(f"{command_context} must set both wrapper_path and wrapper_exec")
        if wrapper_path is not None and wrapper_exec is not None:
            wrapper = HOME / wrapper_path
            wrapper.parent.mkdir(parents=True, exist_ok=True)
            wrapper.write_text(f'#!/bin/bash\nexec "$HOME/{wrapper_exec}" "$@"\n')
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

    packages = require_string_list(command_cfg, "packages", f"commands.{command}")
    run(["npm", "install", "-g", *packages])
    return True


def install_uv_tool(command: str, command_cfg: dict[str, Any]) -> bool:
    if not command_exists("uv"):
        print(f"uv unavailable can't install {command}", file=sys.stderr)
        return False

    package = require_string(command_cfg, "package", f"commands.{command}")
    run(["uv", "tool", "install", package])

    install_hook = get_optional_bool(
        command_cfg,
        "post_install_pre_commit_hook",
        f"commands.{command}",
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

    package = require_string(command_cfg, "package", f"commands.{command}")
    run(["go", "install", package])
    return True


def install_rustup_component(command: str, command_cfg: dict[str, Any]) -> bool:
    if not command_exists("rustup"):
        print(f"ERROR: rustup unavailable can't install {command}", file=sys.stderr)
        return False

    component = require_string(command_cfg, "component", f"commands.{command}")
    run(["rustup", "component", "add", component])
    return True


def enumerate_arch_specs(command: str, command_cfg: dict[str, Any]) -> list[SelectedArchSpec]:
    arch_context = f"commands.{command}.arch"
    arch_cfg = command_cfg.get("arch")

    if isinstance(arch_cfg, dict):
        entries: list[SelectedArchSpec] = []
        for arch_name, arch_spec in arch_cfg.items():
            normalized = normalize_arch(arch_name)
            if normalized is None:
                raise ConfigError(f"{arch_context}.{arch_name} uses unsupported architecture name")
            spec_context = f"{arch_context}.{normalized}"
            entries.append(
                SelectedArchSpec(
                    context=spec_context,
                    spec=parse_mapping(arch_spec, spec_context),
                )
            )
        return entries

    if isinstance(arch_cfg, list):
        entries = []
        for index, raw_entry in enumerate(arch_cfg):
            entry_context = f"{arch_context}[{index}]"
            entry = parse_mapping(raw_entry, entry_context)
            entry_arch = require_string(entry, "arch", entry_context)
            if normalize_arch(entry_arch) is None:
                raise ConfigError(f"{entry_context}.arch has unsupported value '{entry_arch}'")
            entries.append(SelectedArchSpec(context=entry_context, spec=entry))
        return entries

    raise ConfigError(f"{arch_context} must be a table or an array of tables")


def validate_required_field_for_arch_type(
    command: str,
    command_cfg: dict[str, Any],
    key: str,
    arch_specs: list[SelectedArchSpec],
) -> None:
    command_context = f"commands.{command}"
    if key in command_cfg:
        parse_string(command_cfg[key], f"{command_context}.{key}")
        return
    if not arch_specs:
        raise ConfigError(f"{command_context}.arch must define at least one architecture")

    for entry in arch_specs:
        if key not in entry.spec:
            raise ConfigError(f"{entry.context}.{key} is required")
        parse_string(entry.spec[key], f"{entry.context}.{key}")


def validate_type_specific(command: str, command_cfg: dict[str, Any]) -> None:
    command_type = require_string(command_cfg, "type", f"commands.{command}")

    if command_type in {
        "archive_binary",
        "archive_extract",
    }:
        arch_specs = enumerate_arch_specs(command, command_cfg)
        validate_required_field_for_arch_type(command, command_cfg, "url", arch_specs)
        validate_required_field_for_arch_type(command, command_cfg, "sha256", arch_specs)
    else:
        arch_specs = []

    if command_type == "archive_binary":
        has_copies = "file_copies" in command_cfg or any(
            "file_copies" in e.spec for e in arch_specs
        )
        if not has_copies:
            raise ConfigError(f"commands.{command}.file_copies is required")
        if "file_copies" in command_cfg:
            validate_file_copies_shape(
                command_cfg["file_copies"], f"commands.{command}.file_copies"
            )
        for entry in arch_specs:
            if "file_copies" in entry.spec:
                validate_file_copies_shape(
                    entry.spec["file_copies"], f"{entry.context}.file_copies"
                )
    elif command_type == "archive_extract":
        validate_required_field_for_arch_type(command, command_cfg, "destination", arch_specs)
        for entry in arch_specs:
            wrapper_path = get_optional_string(entry.spec, "wrapper_path", entry.context)
            wrapper_exec = get_optional_string(entry.spec, "wrapper_exec", entry.context)
            if (wrapper_path is None) != (wrapper_exec is None):
                raise ConfigError(f"{entry.context} must set both wrapper_path and wrapper_exec")
    elif command_type == "npm_global":
        require_string_list(command_cfg, "packages", f"commands.{command}")
    elif command_type == "uv_tool":
        require_string(command_cfg, "package", f"commands.{command}")
        if "post_install_pre_commit_hook" in command_cfg:
            parse_bool(command_cfg["post_install_pre_commit_hook"], f"commands.{command}")
    elif command_type == "go_install":
        require_string(command_cfg, "package", f"commands.{command}")
    elif command_type == "rustup_component":
        require_string(command_cfg, "component", f"commands.{command}")
    else:
        raise ConfigError(f"Unsupported command type '{command_type}' for commands.{command}")


def load_config(path: Path) -> dict[str, dict[str, Any]]:
    try:
        raw = path.read_bytes()
    except OSError as exc:
        raise ConfigError(f"Unable to read config at {path}: {exc}") from exc

    try:
        parsed = tomllib.loads(raw.decode("utf-8"))
    except (tomllib.TOMLDecodeError, UnicodeDecodeError) as exc:
        raise ConfigError(f"Unable to parse TOML config at {path}: {exc}") from exc

    root = parse_mapping(parsed, "root")
    commands_raw = require_mapping(root, "commands", "root")

    commands: dict[str, dict[str, Any]] = {}
    for name, cfg in commands_raw.items():
        command_name = parse_string(name, "command name")
        command_cfg = parse_mapping(cfg, f"commands.{command_name}")
        validate_type_specific(command_name, command_cfg)
        commands[command_name] = command_cfg

    if not commands:
        raise ConfigError("root.commands must define at least one command")
    return commands


def install_command(command: str, command_cfg: dict[str, Any], arch: str) -> bool:
    command_type = require_string(command_cfg, "type", f"commands.{command}")

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
