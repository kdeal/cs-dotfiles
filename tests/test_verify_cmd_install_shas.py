import importlib.util
import sys
import unittest
from pathlib import Path

REPO_ROOT = Path(__file__).resolve().parents[1]

SPEC = importlib.util.spec_from_file_location(
    "cmd_install", REPO_ROOT / "scripts" / "cmd_install.py"
)
assert SPEC is not None
assert SPEC.loader is not None
cmd_install = importlib.util.module_from_spec(SPEC)
sys.modules[SPEC.name] = cmd_install
SPEC.loader.exec_module(cmd_install)


class VerifyConfiguredArchiveShasTests(unittest.TestCase):
    def test_downloads_and_verifies_all_configured_archive_shas(self) -> None:
        commands = cmd_install.load_config(REPO_ROOT / "cmd_install.toml")

        for name, cfg in commands.items():
            command_type = cmd_install.parse(cfg, "type", f"commands.{name}", "string")
            if command_type not in {"archive_binary", "archive_extract"}:
                continue

            for selected_arch in cmd_install.enumerate_arch_specs(name, cfg):
                arch = cmd_install.normalize_arch(selected_arch.spec["arch"])
                variables = cmd_install.collect_template_vars(cfg, selected_arch, arch)
                url = cmd_install.resolve_string_value(cfg, "url", f"commands.{name}", variables)
                sha256 = cmd_install.resolve_selected_arch_string_value(
                    selected_arch,
                    "sha256",
                    variables,
                )

                with self.subTest(command=name, file=url):
                    self.assertIsNotNone(arch)
                    try:
                        downloaded = cmd_install.download_with_sha256(url, sha256)
                    except cmd_install.InstallError:
                        downloaded = None

                    self.assertIsNotNone(
                        downloaded, f"Failed to download {url} for {name} on arch {arch}"
                    )

                    if downloaded is not None:
                        downloaded.unlink(missing_ok=True)


if __name__ == "__main__":
    unittest.main()
