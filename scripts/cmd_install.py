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
import gzip
import hashlib
import platform
import shutil
import subprocess
import sys
import tarfile
import tempfile
import urllib.request
from collections.abc import Callable
from dataclasses import dataclass
from pathlib import Path

HOME = Path.home()
CACHE_DIR = HOME / ".cache"
BIN_DIR = HOME / ".local" / "bin"
LUA_LS_HOME = HOME / ".local" / "share" / "lua_ls"


@dataclass(frozen=True)
class ArchiveInstallSpec:
    name: str
    url: str
    sha256: str


@dataclass(frozen=True)
class ArchiveBinaryInstallSpec:
    archive: ArchiveInstallSpec
    file_copies: tuple[tuple[str, str], ...]


ARCH_ALIASES = {
    "amd64": "amd64",
    "x86_64": "amd64",
    "x64": "amd64",
    "arm64": "arm64",
    "aarch64": "arm64",
}


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


def install_archive_binary(spec: ArchiveInstallSpec, file_copies: list[tuple[str, str]]) -> bool:
    tmp_file = download_with_sha256(spec.url, spec.sha256)
    if tmp_file is None:
        print(f"Hashes don't match expected for {spec.name}", file=sys.stderr)
        return False

    try:
        with tempfile.TemporaryDirectory(dir=CACHE_DIR) as extract_dir:
            extract_root = Path(extract_dir)
            extract_tar_gz(tmp_file, extract_root)
            for source_rel, dest_rel in file_copies:
                copy_file(extract_root / source_rel, HOME / dest_rel)
    except (FileNotFoundError, OSError, tarfile.TarError, ValueError) as exc:
        print(f"Failed to install {spec.name}: {exc}", file=sys.stderr)
        return False
    finally:
        tmp_file.unlink(missing_ok=True)

    return True


SIMPLE_ARCHIVE_BINARY_COMMANDS: dict[str, dict[str, ArchiveBinaryInstallSpec]] = {
    "rg": {
        "amd64": ArchiveBinaryInstallSpec(
            archive=ArchiveInstallSpec(
                name="rg",
                url="https://github.com/BurntSushi/ripgrep/releases/download/14.1.0/ripgrep-14.1.0-x86_64-unknown-linux-musl.tar.gz",
                sha256="f84757b07f425fe5cf11d87df6644691c644a5cd2348a2c670894272999d3ba7",
            ),
            file_copies=(
                ("ripgrep-14.1.0-x86_64-unknown-linux-musl/rg", ".local/bin/rg"),
                (
                    "ripgrep-14.1.0-x86_64-unknown-linux-musl/complete/rg.fish",
                    ".config/fish/completions/rg.fish",
                ),
            ),
        )
    },
    "delta": {
        "amd64": ArchiveBinaryInstallSpec(
            archive=ArchiveInstallSpec(
                name="delta",
                url="https://github.com/dandavison/delta/releases/download/0.18.2/delta-0.18.2-x86_64-unknown-linux-musl.tar.gz",
                sha256="b7ea845004762358a00ef9127dd9fd723e333c7e4b9cb1da220c3909372310ee",
            ),
            file_copies=(("delta-0.18.2-x86_64-unknown-linux-musl/delta", ".local/bin/delta"),),
        )
    },
    "bat": {
        "amd64": ArchiveBinaryInstallSpec(
            archive=ArchiveInstallSpec(
                name="bat",
                url="https://github.com/sharkdp/bat/releases/download/v0.24.0/bat-v0.24.0-x86_64-unknown-linux-musl.tar.gz",
                sha256="d39a21e3da57fe6a3e07184b3c1dc245f8dba379af569d3668b6dcdfe75e3052",
            ),
            file_copies=(
                ("bat-v0.24.0-x86_64-unknown-linux-musl/bat", ".local/bin/bat"),
                (
                    "bat-v0.24.0-x86_64-unknown-linux-musl/autocomplete/bat.fish",
                    ".config/fish/completions/bat.fish",
                ),
            ),
        )
    },
    "eza": {
        "amd64": ArchiveBinaryInstallSpec(
            archive=ArchiveInstallSpec(
                name="eza",
                url="https://github.com/eza-community/eza/releases/download/v0.20.14/eza_x86_64-unknown-linux-musl.tar.gz",
                sha256="cb5953a866a5fb3ec8d4fb0f6b0275511c5caa4d6b3019e5378d970ea85d2ef0",
            ),
            file_copies=(("eza", ".local/bin/eza"),),
        )
    },
    "fd": {
        "amd64": ArchiveBinaryInstallSpec(
            archive=ArchiveInstallSpec(
                name="fd",
                url="https://github.com/sharkdp/fd/releases/download/v10.2.0/fd-v10.2.0-x86_64-unknown-linux-musl.tar.gz",
                sha256="d9bfa25ec28624545c222992e1b00673b7c9ca5eb15393c40369f10b28f9c932",
            ),
            file_copies=(
                ("fd-v10.2.0-x86_64-unknown-linux-musl/fd", ".local/bin/fd"),
                (
                    "fd-v10.2.0-x86_64-unknown-linux-musl/autocomplete/fd.fish",
                    ".config/fish/completions/fd.fish",
                ),
            ),
        )
    },
    "just": {
        "amd64": ArchiveBinaryInstallSpec(
            archive=ArchiveInstallSpec(
                name="just",
                url="https://github.com/casey/just/releases/download/1.38.0/just-1.38.0-x86_64-unknown-linux-musl.tar.gz",
                sha256="c803e67fd7b0af01667bd537197bc3df319938eacf9e8d51a441c71d03035bb5",
            ),
            file_copies=(
                ("just", ".local/bin/just"),
                ("just.1", ".local/share/man/man1/just.1"),
                ("completions/just.fish", ".config/fish/completions/just.fish"),
            ),
        )
    },
}

NPM_GLOBAL_COMMANDS: dict[str, list[str]] = {
    "typescript-language-server": ["typescript", "typescript-language-server"],
    "tailwindcss-language-server": ["@tailwindcss/language-server"],
    "css-language-server": ["vscode-langservers-extracted"],
    "html-language-server": ["vscode-langservers-extracted"],
    "opencode": ["opencode-ai@latest"],
    "copilot-language-server": ["@github/copilot-language-server"],
}


def install_nvim(arch: str) -> bool:
    specs: dict[str, tuple[ArchiveInstallSpec, str]] = {
        "amd64": (
            ArchiveInstallSpec(
                name="nvim",
                url="https://github.com/neovim/neovim/releases/download/v0.11.2/nvim-linux-x86_64.tar.gz",
                sha256="a9b24157672eb218ff3e33ef3f8c08db26f8931c5c04bdb0e471371dd1dfe63e",
            ),
            "nvim-linux-x86_64",
        )
    }
    selected = specs.get(arch)
    if selected is None:
        print(f"{arch} is not yet supported for nvim", file=sys.stderr)
        return False

    spec, extract_dir_name = selected
    tmp_file = download_with_sha256(spec.url, spec.sha256)
    if tmp_file is None:
        print("Hashes don't match expected for nvim", file=sys.stderr)
        return False

    try:
        with tempfile.TemporaryDirectory(dir=CACHE_DIR) as extract_dir:
            extract_root = Path(extract_dir)
            extract_tar_gz(tmp_file, extract_root)
            run(
                [
                    "rsync",
                    "-a",
                    str(extract_root / extract_dir_name) + "/",
                    str(HOME / ".local") + "/",
                ]
            )
    except (
        OSError,
        tarfile.TarError,
        ValueError,
        subprocess.CalledProcessError,
    ) as exc:
        print(f"Failed to install nvim: {exc}", file=sys.stderr)
        return False
    finally:
        tmp_file.unlink(missing_ok=True)

    return True


def install_uv(arch: str) -> bool:
    specs: dict[str, tuple[ArchiveInstallSpec, str]] = {
        "amd64": (
            ArchiveInstallSpec(
                name="uv",
                url="https://github.com/astral-sh/uv/releases/download/0.9.24/uv-x86_64-unknown-linux-gnu.tar.gz",
                sha256="fb13ad85106da6b21dd16613afca910994446fe94a78ee0b5bed9c75cd066078",
            ),
            "uv-x86_64-unknown-linux-gnu",
        )
    }
    selected = specs.get(arch)
    if selected is None:
        print(f"{arch} is not yet supported for uv", file=sys.stderr)
        return False

    spec, extract_dir_name = selected
    tmp_file = download_with_sha256(spec.url, spec.sha256)
    if tmp_file is None:
        print("Error: Hashes don't match expected for uv", file=sys.stderr)
        return False

    try:
        with tempfile.TemporaryDirectory(dir=CACHE_DIR) as extract_dir:
            extract_root = Path(extract_dir)
            extract_tar_gz(tmp_file, extract_root)
            uv_dir = extract_root / extract_dir_name
            for uv_binary in uv_dir.iterdir():
                copy_file(uv_binary, BIN_DIR / uv_binary.name)
    except (FileNotFoundError, OSError, tarfile.TarError, ValueError) as exc:
        print(f"Failed to install uv: {exc}", file=sys.stderr)
        return False
    finally:
        tmp_file.unlink(missing_ok=True)

    return True


def install_lua_ls(arch: str) -> bool:
    specs: dict[str, ArchiveInstallSpec] = {
        "amd64": ArchiveInstallSpec(
            name="lua_ls",
            url="https://github.com/LuaLS/lua-language-server/releases/download/3.13.5/lua-language-server-3.13.5-linux-x64.tar.gz",
            sha256="5d4316291b8c79b145002318fbb7cc294a327c314e2711e590609b178478eb59",
        )
    }
    spec = specs.get(arch)
    if spec is None:
        print(f"{arch} is not yet supported for lua_ls", file=sys.stderr)
        return False

    tmp_file = download_with_sha256(spec.url, spec.sha256)
    if tmp_file is None:
        print("Hashes don't match expected", file=sys.stderr)
        return False

    try:
        LUA_LS_HOME.mkdir(parents=True, exist_ok=True)
        extract_tar_gz(tmp_file, LUA_LS_HOME)
        wrapper = BIN_DIR / "lua-language-server"
        wrapper.write_text(
            '#!/bin/bash\nexec "$HOME/.local/share/lua_ls/bin/lua-language-server" "$@"\n'
        )
        wrapper.chmod(0o755)
    except (OSError, tarfile.TarError, ValueError) as exc:
        print(f"Failed to install lua_ls: {exc}", file=sys.stderr)
        return False
    finally:
        tmp_file.unlink(missing_ok=True)

    return True


def install_rust_analyzer(arch: str) -> bool:
    specs: dict[str, ArchiveInstallSpec] = {
        "amd64": ArchiveInstallSpec(
            name="rust-analyzer",
            url="https://github.com/rust-lang/rust-analyzer/releases/download/2024-02-19/rust-analyzer-x86_64-unknown-linux-musl.gz",
            sha256="80d1a59e87820b65d4a86e6994a5dfda14edfd9fb5133a2394f28634bbc19eb2",
        )
    }
    spec = specs.get(arch)
    if spec is None:
        print(f"{arch} is not yet supported for rust-analyzer", file=sys.stderr)
        return False

    tmp_file = download_with_sha256(spec.url, spec.sha256)
    if tmp_file is None:
        print("Error: Hashes don't match expected for rust-analyzer", file=sys.stderr)
        return False

    try:
        with (
            gzip.open(tmp_file, "rb") as gz_handle,
            (BIN_DIR / "rust-analyzer").open("wb") as out,
        ):
            shutil.copyfileobj(gz_handle, out)
        (BIN_DIR / "rust-analyzer").chmod(0o755)
    except OSError as exc:
        print(f"Failed to install rust-analyzer: {exc}", file=sys.stderr)
        return False
    finally:
        tmp_file.unlink(missing_ok=True)

    return True


CUSTOM_ARCHIVE_COMMANDS: dict[str, Callable[[str], bool]] = {
    "uv": install_uv,
    "lua_ls": install_lua_ls,
    "rust-analyzer": install_rust_analyzer,
}


class CommandInstaller:
    def install(self, arch: str) -> bool:
        raise NotImplementedError


@dataclass(frozen=True)
class FunctionCommandInstaller(CommandInstaller):
    installer: Callable[[str], bool]

    def install(self, arch: str) -> bool:
        return self.installer(arch)


@dataclass(frozen=True)
class ArchiveCommandInstaller(CommandInstaller):
    command: str

    def install(self, arch: str) -> bool:
        return install_simple_archive_command(self.command, arch)


@dataclass(frozen=True)
class NpmCommandInstaller(CommandInstaller):
    command: str

    def install(self, arch: str) -> bool:
        del arch
        return install_npm_command(self.command)


class GoplsInstaller(CommandInstaller):
    def install(self, arch: str) -> bool:
        del arch
        if command_exists("go"):
            run(["go", "install", "golang.org/x/tools/gopls@latest"])
            return True
        print("Go unavailable can't install gopls", file=sys.stderr)
        return False


@dataclass(frozen=True)
class UvToolInstaller(CommandInstaller):
    package: str
    command_name: str

    def install(self, arch: str) -> bool:
        del arch
        if not command_exists("uv"):
            print(f"uv unavailable can't install {self.command_name}", file=sys.stderr)
            return False
        run(["uv", "tool", "install", self.package])
        return True


class PreCommitInstaller(UvToolInstaller):
    def __init__(self) -> None:
        super().__init__(package="pre-commit", command_name="pre-commit")

    def install(self, arch: str) -> bool:
        if not super().install(arch):
            return False
        if (run(["git", "rev-parse"], check=False).returncode == 0) and command_exists(
            "pre-commit"
        ):
            run(["pre-commit", "install"], check=False)
        return True


class TyInstaller(UvToolInstaller):
    def __init__(self) -> None:
        super().__init__(package="ty@latest", command_name="ty")


class RustfmtInstaller(CommandInstaller):
    def install(self, arch: str) -> bool:
        del arch
        if command_exists("rustup"):
            run(["rustup", "component", "add", "rustfmt"])
            return True
        print("ERROR: rustup unavailable can't install rustfmt", file=sys.stderr)
        return False


def install_simple_archive_command(command: str, arch: str) -> bool:
    if command in SIMPLE_ARCHIVE_BINARY_COMMANDS:
        binary_spec = SIMPLE_ARCHIVE_BINARY_COMMANDS[command].get(arch)
        if binary_spec is None:
            print(f"{arch} is not yet supported for {command}", file=sys.stderr)
            return False
        return install_archive_binary(binary_spec.archive, list(binary_spec.file_copies))
    installer = CUSTOM_ARCHIVE_COMMANDS.get(command)
    if installer is None:
        print(f"Unsupported archive command: {command}", file=sys.stderr)
        return False
    return installer(arch)


def install_npm_command(command: str) -> bool:
    if not command_exists("npm"):
        print(f"npm unavailable can't install {command}", file=sys.stderr)
        return False

    packages = NPM_GLOBAL_COMMANDS[command]
    run(["npm", "install", "-g", *packages])
    return True


COMMAND_INSTALLERS: dict[str, CommandInstaller] = {
    "nvim": FunctionCommandInstaller(install_nvim),
    "rg": ArchiveCommandInstaller("rg"),
    "delta": ArchiveCommandInstaller("delta"),
    "bat": ArchiveCommandInstaller("bat"),
    "eza": ArchiveCommandInstaller("eza"),
    "fd": ArchiveCommandInstaller("fd"),
    "lua_ls": ArchiveCommandInstaller("lua_ls"),
    "rust-analyzer": ArchiveCommandInstaller("rust-analyzer"),
    "just": ArchiveCommandInstaller("just"),
    "uv": ArchiveCommandInstaller("uv"),
    "typescript-language-server": NpmCommandInstaller("typescript-language-server"),
    "tailwindcss-language-server": NpmCommandInstaller("tailwindcss-language-server"),
    "css-language-server": NpmCommandInstaller("css-language-server"),
    "html-language-server": NpmCommandInstaller("html-language-server"),
    "opencode": NpmCommandInstaller("opencode"),
    "copilot-language-server": NpmCommandInstaller("copilot-language-server"),
    "gopls": GoplsInstaller(),
    "pre-commit": PreCommitInstaller(),
    "ty": TyInstaller(),
    "rustfmt": RustfmtInstaller(),
}


def install_command(command: str, arch: str) -> bool:
    installer = COMMAND_INSTALLERS.get(command)
    if installer is None:
        print(f'Command not recognized: "{command}"', file=sys.stderr)
        return False
    return installer.install(arch)


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("commands", nargs="+", help="Command names to install")
    parser.add_argument(
        "--arch",
        type=parse_arch,
        default=detect_default_arch(),
        help="Target architecture (amd64/x86_64/x64 or arm64/aarch64)",
    )
    return parser.parse_args()


def main() -> int:
    args = parse_args()
    ensure_dirs()
    had_errors = False
    for cmd in args.commands:
        try:
            if not install_command(cmd, args.arch):
                had_errors = True
        except (
            subprocess.CalledProcessError,
            OSError,
            tarfile.TarError,
            ValueError,
        ) as exc:
            had_errors = True
            print(f"Failed to install {cmd}: {exc}", file=sys.stderr)
    return 1 if had_errors else 0


if __name__ == "__main__":
    raise SystemExit(main())
