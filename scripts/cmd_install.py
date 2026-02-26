#!/usr/bin/env -S uv run --script
# /// script
# requires-python = ">=3.11"
# dependencies = []
# ///
"""Install extra commands that I might want.

Python port of `xdg_config/fish/functions/cmd_install.fish`.
"""

from __future__ import annotations

import argparse
import gzip
import hashlib
import shutil
import subprocess
import sys
import tarfile
import tempfile
import urllib.request
from dataclasses import dataclass
from pathlib import Path

HOME = Path.home()
CACHE_DIR = HOME / ".cache"
BIN_DIR = HOME / ".local" / "bin"
FISH_COMPLETIONS_DIR = HOME / ".config" / "fish" / "completions"
MAN1_DIR = HOME / ".local" / "share" / "man" / "man1"
LUA_LS_HOME = HOME / ".local" / "share" / "lua_ls"


@dataclass(frozen=True)
class ArchiveInstallSpec:
    name: str
    url: str
    sha256: str


def ensure_dirs() -> None:
    for path in (CACHE_DIR, BIN_DIR, FISH_COMPLETIONS_DIR, MAN1_DIR):
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

    digest = hashlib.sha256(tmp_path.read_bytes()).hexdigest()
    if digest != expected_sha256:
        tmp_path.unlink(missing_ok=True)
        return None
    return tmp_path


def extract_tar_gz(archive: Path, destination: Path) -> None:
    with tarfile.open(archive, mode="r:gz") as tar:
        tar.extractall(destination)


def copy_file(source: Path, destination: Path) -> None:
    destination.parent.mkdir(parents=True, exist_ok=True)
    shutil.copy2(source, destination)


def install_archive_binary(spec: ArchiveInstallSpec, file_copies: list[tuple[str, str]]) -> bool:
    tmp_file = download_with_sha256(spec.url, spec.sha256)
    if tmp_file is None:
        print(f"Hashes don't match expected for {spec.name}", file=sys.stderr)
        return False

    extract_tar_gz(tmp_file, CACHE_DIR)
    for source_rel, dest_rel in file_copies:
        copy_file(CACHE_DIR / source_rel, HOME / dest_rel)
    return True


def install_nvim() -> None:
    spec = ArchiveInstallSpec(
        name="nvim",
        url="https://github.com/neovim/neovim/releases/download/v0.11.2/nvim-linux-x86_64.tar.gz",
        sha256="a9b24157672eb218ff3e33ef3f8c08db26f8931c5c04bdb0e471371dd1dfe63e",
    )
    tmp_file = download_with_sha256(spec.url, spec.sha256)
    if tmp_file is None:
        print("Hashes don't match expected", file=sys.stderr)
        return

    extract_tar_gz(tmp_file, CACHE_DIR)
    run(["rsync", "-a", str(CACHE_DIR / "nvim-linux-x86_64") + "/", str(HOME / ".local") + "/"])


def install_rg() -> None:
    spec = ArchiveInstallSpec(
        name="rg",
        url="https://github.com/BurntSushi/ripgrep/releases/download/14.1.0/ripgrep-14.1.0-x86_64-unknown-linux-musl.tar.gz",
        sha256="f84757b07f425fe5cf11d87df6644691c644a5cd2348a2c670894272999d3ba7",
    )
    install_archive_binary(
        spec,
        [
            ("ripgrep-14.1.0-x86_64-unknown-linux-musl/rg", ".local/bin/rg"),
            ("ripgrep-14.1.0-x86_64-unknown-linux-musl/complete/rg.fish", ".config/fish/completions/rg.fish"),
        ],
    )


def install_simple_archive_command(command: str) -> None:
    match command:
        case "delta":
            version = "0.18.2"
            spec = ArchiveInstallSpec(
                name="delta",
                url=f"https://github.com/dandavison/delta/releases/download/{version}/delta-{version}-x86_64-unknown-linux-musl.tar.gz",
                sha256="b7ea845004762358a00ef9127dd9fd723e333c7e4b9cb1da220c3909372310ee",
            )
            install_archive_binary(spec, [(f"delta-{version}-x86_64-unknown-linux-musl/delta", ".local/bin/delta")])
        case "bat":
            version = "0.24.0"
            spec = ArchiveInstallSpec(
                name="bat",
                url=f"https://github.com/sharkdp/bat/releases/download/v{version}/bat-v{version}-x86_64-unknown-linux-musl.tar.gz",
                sha256="d39a21e3da57fe6a3e07184b3c1dc245f8dba379af569d3668b6dcdfe75e3052",
            )
            install_archive_binary(
                spec,
                [
                    (f"bat-v{version}-x86_64-unknown-linux-musl/bat", ".local/bin/bat"),
                    (f"bat-v{version}-x86_64-unknown-linux-musl/autocomplete/bat.fish", ".config/fish/completions/bat.fish"),
                ],
            )
        case "eza":
            spec = ArchiveInstallSpec(
                name="eza",
                url="https://github.com/eza-community/eza/releases/download/v0.20.14/eza_x86_64-unknown-linux-musl.tar.gz",
                sha256="cb5953a866a5fb3ec8d4fb0f6b0275511c5caa4d6b3019e5378d970ea85d2ef0",
            )
            install_archive_binary(spec, [("eza", ".local/bin/eza")])
        case "fd":
            version = "10.2.0"
            spec = ArchiveInstallSpec(
                name="fd",
                url=f"https://github.com/sharkdp/fd/releases/download/v{version}/fd-v{version}-x86_64-unknown-linux-musl.tar.gz",
                sha256="d9bfa25ec28624545c222992e1b00673b7c9ca5eb15393c40369f10b28f9c932",
            )
            install_archive_binary(
                spec,
                [
                    (f"fd-v{version}-x86_64-unknown-linux-musl/fd", ".local/bin/fd"),
                    (f"fd-v{version}-x86_64-unknown-linux-musl/autocomplete/fd.fish", ".config/fish/completions/fd.fish"),
                ],
            )
        case "just":
            spec = ArchiveInstallSpec(
                name="just",
                url="https://github.com/casey/just/releases/download/1.38.0/just-1.38.0-x86_64-unknown-linux-musl.tar.gz",
                sha256="c803e67fd7b0af01667bd537197bc3df319938eacf9e8d51a441c71d03035bb5",
            )
            tmp_file = download_with_sha256(spec.url, spec.sha256)
            if tmp_file is None:
                print("Error: Hashes don't match expected for just", file=sys.stderr)
                return

            just_cache = CACHE_DIR / "just"
            just_cache.mkdir(parents=True, exist_ok=True)
            extract_tar_gz(tmp_file, just_cache)
            copy_file(just_cache / "just", BIN_DIR / "just")
            copy_file(just_cache / "just.1", MAN1_DIR / "just.1")
            copy_file(just_cache / "completions" / "just.fish", FISH_COMPLETIONS_DIR / "just.fish")
        case "uv":
            version = "0.9.24"
            spec = ArchiveInstallSpec(
                name="uv",
                url=f"https://github.com/astral-sh/uv/releases/download/{version}/uv-x86_64-unknown-linux-gnu.tar.gz",
                sha256="fb13ad85106da6b21dd16613afca910994446fe94a78ee0b5bed9c75cd066078",
            )
            tmp_file = download_with_sha256(spec.url, spec.sha256)
            if tmp_file is None:
                print("Error: Hashes don't match expected for uv", file=sys.stderr)
                return

            extract_tar_gz(tmp_file, CACHE_DIR)
            uv_dir = CACHE_DIR / "uv-x86_64-unknown-linux-gnu"
            for uv_binary in uv_dir.iterdir():
                copy_file(uv_binary, BIN_DIR / uv_binary.name)
        case "lua_ls":
            spec = ArchiveInstallSpec(
                name="lua_ls",
                url="https://github.com/LuaLS/lua-language-server/releases/download/3.13.5/lua-language-server-3.13.5-linux-x64.tar.gz",
                sha256="5d4316291b8c79b145002318fbb7cc294a327c314e2711e590609b178478eb59",
            )
            tmp_file = download_with_sha256(spec.url, spec.sha256)
            if tmp_file is None:
                print("Hashes don't match expected", file=sys.stderr)
                return

            LUA_LS_HOME.mkdir(parents=True, exist_ok=True)
            extract_tar_gz(tmp_file, LUA_LS_HOME)
            wrapper = BIN_DIR / "lua-language-server"
            wrapper.write_text('#!/bin/bash\nexec "$HOME/.local/share/lua_ls/bin/lua-language-server" "$@"\n')
            wrapper.chmod(0o755)
        case "rust-analyzer":
            spec = ArchiveInstallSpec(
                name="rust-analyzer",
                url="https://github.com/rust-lang/rust-analyzer/releases/download/2024-02-19/rust-analyzer-x86_64-unknown-linux-musl.gz",
                sha256="80d1a59e87820b65d4a86e6994a5dfda14edfd9fb5133a2394f28634bbc19eb2",
            )
            tmp_file = download_with_sha256(spec.url, spec.sha256)
            if tmp_file is None:
                print("Error: Hashes don't match expected for rust-analyzer", file=sys.stderr)
                return

            with gzip.open(tmp_file, "rb") as gz_handle, (BIN_DIR / "rust-analyzer").open("wb") as out:
                shutil.copyfileobj(gz_handle, out)
            (BIN_DIR / "rust-analyzer").chmod(0o755)
        case _:
            print(f"Unsupported archive command: {command}", file=sys.stderr)


def install_command(command: str) -> None:
    match command:
        case "nvim":
            install_nvim()
        case "rg":
            install_rg()
        case "delta" | "bat" | "eza" | "fd" | "lua_ls" | "rust-analyzer" | "just" | "uv":
            install_simple_archive_command(command)
        case "gopls":
            if command_exists("go"):
                run(["go", "install", "golang.org/x/tools/gopls@latest"])
            else:
                print("Go unavailable can't install")
        case "pre-commit":
            if command_exists("uv"):
                run(["uv", "tool", "install", "pre-commit"])
                if (run(["git", "rev-parse"], check=False).returncode == 0) and command_exists("pre-commit"):
                    run(["pre-commit", "install"], check=False)
            else:
                print("uv unavailable can't install")
        case "ty":
            if command_exists("uv"):
                run(["uv", "tool", "install", "ty@latest"])
            else:
                print("uv unavailable can't install")
        case "rustfmt":
            if command_exists("rustup"):
                run(["rustup", "component", "add", "rustfmt"])
            else:
                print("ERROR: rustup unavailable can't install rustfmt", file=sys.stderr)
        case "typescript-language-server":
            if command_exists("npm"):
                run(["npm", "install", "-g", "typescript", "typescript-language-server"])
        case "tailwindcss-language-server":
            if command_exists("npm"):
                run(["npm", "install", "-g", "@tailwindcss/language-server"])
        case "css-language-server" | "html-language-server":
            if command_exists("npm"):
                run(["npm", "install", "-g", "vscode-langservers-extracted"])
        case "opencode":
            if command_exists("npm"):
                run(["npm", "install", "-g", "opencode-ai@latest"])
            else:
                print("npm unavailable can't install opencode")
        case "copilot-language-server":
            if command_exists("npm"):
                run(["npm", "install", "-g", "@github/copilot-language-server"])
            else:
                print("npm unavailable can't install copilot-language-server")
        case _:
            print(f'Command not recognized: "{command}"')


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("commands", nargs="+", help="Command names to install")
    return parser.parse_args()


def main() -> int:
    args = parse_args()
    ensure_dirs()
    for cmd in args.commands:
        install_command(cmd)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
