import importlib.util
import sys
import tarfile
import tempfile
import unittest
from pathlib import Path
from unittest import mock

MODULE_PATH = Path(__file__).resolve().parents[1] / "scripts" / "cmd_install.py"
SPEC = importlib.util.spec_from_file_location("cmd_install", MODULE_PATH)
assert SPEC is not None
assert SPEC.loader is not None
cmd_install = importlib.util.module_from_spec(SPEC)
sys.modules[SPEC.name] = cmd_install
SPEC.loader.exec_module(cmd_install)


class LoadConfigTests(unittest.TestCase):
    def write_config(self, contents: str) -> Path:
        temp_dir = tempfile.TemporaryDirectory()
        self.addCleanup(temp_dir.cleanup)
        config_path = Path(temp_dir.name) / "cmd_install.toml"
        config_path.write_text(contents, encoding="utf-8")
        return config_path

    def test_rejects_unknown_command_key(self) -> None:
        config_path = self.write_config(
            """
            [commands.demo]
            type = "npm_global"
            packages = ["demo"]
            packagse = ["typo"]
            """
        )

        with self.assertRaises(cmd_install.ConfigError) as context:
            cmd_install.load_config(config_path)

        self.assertIn("commands.demo has unsupported keys: packagse", str(context.exception))

    def test_rejects_unknown_file_copy_key(self) -> None:
        config_path = self.write_config(
            """
            [commands.demo]
            type = "archive_binary"
            url = "https://example.invalid/demo-{arch}.tar.gz"
            file_copies = [
              { source = "demo", destination = ".local/bin/demo", nope = "typo" },
            ]

            [[commands.demo.arch]]
            arch = "x86_64"
            sha256 = "abc123"
            """
        )

        with self.assertRaises(cmd_install.ConfigError) as context:
            cmd_install.load_config(config_path)

        self.assertIn(
            "commands.demo.file_copies[0] has unsupported keys: nope",
            str(context.exception),
        )

    def test_rejects_duplicate_arch_entries(self) -> None:
        config_path = self.write_config(
            """
            [commands.demo]
            type = "archive_extract"
            url = "https://example.invalid/demo-{arch}.tar.gz"
            destination = ".local/share/demo"

            [[commands.demo.arch]]
            arch = "x86_64"
            sha256 = "first"

            [[commands.demo.arch]]
            arch = "amd64"
            sha256 = "second"
            """
        )

        with self.assertRaises(cmd_install.ConfigError) as context:
            cmd_install.load_config(config_path)

        self.assertIn("duplicates architecture 'amd64'", str(context.exception))


class InstallArchiveExtractTests(unittest.TestCase):
    def setUp(self) -> None:
        self.temp_dir = tempfile.TemporaryDirectory()
        self.addCleanup(self.temp_dir.cleanup)
        self.home = Path(self.temp_dir.name)

        home_patch = mock.patch.object(cmd_install, "HOME", self.home)
        bin_patch = mock.patch.object(cmd_install, "BIN_DIR", self.home / ".local" / "bin")
        home_patch.start()
        bin_patch.start()
        self.addCleanup(home_patch.stop)
        self.addCleanup(bin_patch.stop)

    def make_archive(self, files: dict[str, str]) -> Path:
        staging_dir = Path(self.temp_dir.name) / "staging"
        archive_path = Path(self.temp_dir.name) / "tool.tar.gz"
        if staging_dir.exists():
            for child in staging_dir.iterdir():
                if child.is_dir():
                    for nested in sorted(child.rglob("*"), reverse=True):
                        if nested.is_file() or nested.is_symlink():
                            nested.unlink()
                        elif nested.is_dir():
                            nested.rmdir()
                    child.rmdir()
                else:
                    child.unlink()
        staging_dir.mkdir(parents=True, exist_ok=True)

        for relative_path, contents in files.items():
            file_path = staging_dir / relative_path
            file_path.parent.mkdir(parents=True, exist_ok=True)
            file_path.write_text(contents, encoding="utf-8")

        with tarfile.open(archive_path, mode="w:gz") as archive:
            for file_path in staging_dir.rglob("*"):
                archive.add(file_path, arcname=file_path.relative_to(staging_dir))

        return archive_path

    def test_install_archive_extract_replaces_stale_files_and_writes_wrapper(self) -> None:
        destination = self.home / ".local" / "share" / "demo"
        destination.mkdir(parents=True, exist_ok=True)
        (destination / "stale.txt").write_text("stale", encoding="utf-8")

        archive_path = self.make_archive({"bin/demo": "fresh\n"})
        command_cfg = {
            "type": "archive_extract",
            "url": "https://example.invalid/demo-{arch}.tar.gz",
            "destination": ".local/share/demo",
            "wrapper_path": ".local/bin/demo",
            "wrapper_exec": ".local/share/demo/bin/demo",
            "arch": [{"arch": "x86_64", "sha256": "deadbeef"}],
        }

        with mock.patch.object(cmd_install, "download_with_sha256", return_value=archive_path):
            result = cmd_install.install_archive_extract("demo", command_cfg, "amd64")

        self.assertTrue(result)
        self.assertFalse((destination / "stale.txt").exists())
        self.assertEqual((destination / "bin" / "demo").read_text(encoding="utf-8"), "fresh\n")

        wrapper = self.home / ".local" / "bin" / "demo"
        self.assertEqual(
            wrapper.read_text(encoding="utf-8"),
            '#!/usr/bin/env sh\nexec "$HOME/.local/share/demo/bin/demo" "$@"\n',
        )

    def test_download_with_sha256_surfaces_network_errors(self) -> None:
        with mock.patch.object(
            cmd_install.urllib.request,
            "urlopen",
            side_effect=cmd_install.urllib.error.URLError("boom"),
        ):
            with self.assertRaises(cmd_install.InstallError) as context:
                cmd_install.download_with_sha256("https://example.invalid/demo.tar.gz", "deadbeef")

        self.assertIn(
            "Failed to download https://example.invalid/demo.tar.gz", str(context.exception)
        )


class ExtractTarTests(unittest.TestCase):
    def test_extract_tar_uses_mode_for_archive_extension(self) -> None:
        cases = [
            ("demo.tar", "r:"),
            ("demo.tar.gz", "r:gz"),
            ("demo.tgz", "r:gz"),
            ("demo.tar.bz2", "r:bz2"),
            ("demo.tbz2", "r:bz2"),
            ("demo.tar.xz", "r:xz"),
            ("demo.txz", "r:xz"),
        ]

        for archive_name, expected_mode in cases:
            with self.subTest(archive_name=archive_name):
                archive = Path(archive_name)
                destination = Path("/tmp/extract")
                tar_handle = mock.MagicMock()
                tar_context = mock.MagicMock()
                tar_context.__enter__.return_value = tar_handle
                tar_context.__exit__.return_value = False

                with mock.patch.object(
                    cmd_install.tarfile, "open", return_value=tar_context
                ) as open_mock:
                    cmd_install.extract_tar(archive, destination)

                open_mock.assert_called_once_with(archive, mode=expected_mode)
                tar_handle.extractall.assert_called_once_with(destination, filter="data")


if __name__ == "__main__":
    unittest.main()
