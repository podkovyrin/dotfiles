#!/usr/bin/env python3
"""Check live config links and helper lookup without changing desktop state."""

import json
import os
from pathlib import Path
import re
import shlex
import subprocess
import tempfile
import tomllib
import unittest
from unittest.mock import patch


REPOSITORY = Path(__file__).resolve().parents[2]


def load_helper(relative):
    path = REPOSITORY / relative
    namespace = {"__name__": "helper_under_test", "__file__": str(path)}
    exec(compile(path.read_text(), str(path), "exec"), namespace)
    return namespace


class HelperLookupTests(unittest.TestCase):
    def test_audio_uses_path(self):
        helper = load_helper("scripts/audio-toggle")
        expected = "/test/nix/bin/SwitchAudioSource"
        with patch.object(helper["shutil"], "which", return_value=expected) as lookup:
            self.assertEqual(helper["switch_tool"](), expected)
            lookup.assert_called_once_with("SwitchAudioSource")

    def test_audio_reports_missing_command(self):
        helper = load_helper("scripts/audio-toggle")
        with patch.object(helper["shutil"], "which", return_value=None):
            with self.assertRaisesRegex(RuntimeError, "SwitchAudioSource is missing from PATH"):
                helper["switch_tool"]()

    def test_browser_uses_path(self):
        helper = load_helper("scripts/omniwm-browser")
        expected = "/test/nix/bin/omniwmctl"
        response = subprocess.CompletedProcess(
            [], 0, '{"ok":true,"result":{"payload":{"windows":[]}}}', ""
        )
        with patch.object(helper["shutil"], "which", return_value=expected) as lookup:
            with patch.object(helper["subprocess"], "run", return_value=response) as run:
                self.assertEqual(helper["ctl"]("query", "windows"), {"windows": []})
                lookup.assert_called_once_with("omniwmctl")
                self.assertEqual(
                    run.call_args.args[0],
                    [expected, "query", "windows", "--format", "json"],
                )

    def test_browser_reports_missing_command(self):
        helper = load_helper("scripts/omniwm-browser")
        with patch.object(helper["shutil"], "which", return_value=None):
            with self.assertRaisesRegex(RuntimeError, "omniwmctl is missing from PATH"):
                helper["ctl"]("query", "windows")


class ApplyPreviewTests(unittest.TestCase):
    def run_check_fixture(self, check_exit):
        with tempfile.TemporaryDirectory(prefix="dotfiles-check-test-") as fixture:
            bin_directory = Path(fixture) / "bin"
            bin_directory.mkdir()
            log = Path(fixture) / "calls"
            checker = bin_directory / "system-checks"
            checker.write_text(
                '#!/bin/sh\n'
                'printf "checks:%s\\n" "$*" >> "$TEST_LOG"\n'
                '[ "$1" = /nix/store/test-system ] || exit 98\n'
                f'exit {check_exit}\n'
            )
            nix = bin_directory / "nix"
            nix.write_text(
                '#!/bin/sh\n'
                'printf "nix:%s\\n" "$*" >> "$TEST_LOG"\n'
                'for argument do\n'
                '  case "$argument" in\n'
                '    *#lib.source) printf /nix/store/test-source; exit 0 ;;\n'
                '    *#system-checks) printf "%s\\n" "$TEST_CHECKER"; exit 0 ;;\n'
                '    *#darwinConfigurations.mac.system.outPath)\n'
                '      printf /nix/store/test-system; exit 0 ;;\n'
                '  esac\n'
                'done\nexit 0\n'
            )
            sudo = bin_directory / "sudo"
            sudo.write_text(
                '#!/bin/sh\n'
                'printf "sudo:%s\\n" "$*" >> "$TEST_LOG"\n'
                '# Never permit a test to call the real activation tool.\n'
                '[ "$1" = "$TEST_CHECKER" ] || exit 97\n'
                'exec "$@"\n'
            )
            for executable in (checker, nix, sudo):
                executable.chmod(0o755)
            environment = os.environ.copy()
            environment.update(
                PATH=f"{bin_directory}:{environment.get('PATH', '/usr/bin:/bin')}",
                TEST_LOG=str(log),
                TEST_CHECKER=str(checker),
            )
            result = subprocess.run(
                [str(REPOSITORY / "apply"), "--check"],
                env=environment, capture_output=True, text=True,
            )
            return result, log.read_text()

    def test_check_calls_only_dedicated_checks(self):
        result, calls = self.run_check_fixture(0)
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertIn("checks:/nix/store/test-system", calls)
        self.assertIn("#system-checks --out-link ", calls)
        self.assertNotIn("darwin-rebuild", calls)
        self.assertNotIn("activate", calls)
        self.assertNotIn("switch", calls)

    def test_check_preserves_failure_status_without_activation(self):
        result, calls = self.run_check_fixture(42)
        self.assertEqual(result.returncode, 42, result.stderr)
        self.assertNotIn("darwin-rebuild", calls)
        self.assertNotIn("activate", calls)
        self.assertNotIn("switch", calls)

    def test_preview_quotes_flake_for_zsh(self):
        with tempfile.TemporaryDirectory(prefix="dotfiles-apply-test-") as fixture:
            bin_directory = Path(fixture) / "bin"
            bin_directory.mkdir()
            nix = bin_directory / "nix"
            nix.write_text(
                '#!/bin/sh\nfor argument do\n'
                '  if [ "$argument" = eval ]; then\n'
                '    printf /nix/store/test-source\n    exit 0\n  fi\n'
                'done\nexit 0\n'
            )
            nix.chmod(0o755)
            # A parser regression must not request actual administrator access.
            sudo = bin_directory / "sudo"
            sudo.write_text("#!/bin/sh\nexit 99\n")
            sudo.chmod(0o755)
            environment = os.environ.copy()
            environment["PATH"] = f"{bin_directory}:{environment.get('PATH', '/usr/bin:/bin')}"
            preview = subprocess.run(
                [str(REPOSITORY / "apply"), "--dry-run"],
                env=environment, capture_output=True, text=True, check=True,
            )
            parsed = subprocess.run(
                [
                    "/bin/zsh", "-f", "-o", "extendedglob", "-c",
                    'sudo() { printf "%s\\n" "$@"; }; eval "$1"',
                    "zsh", preview.stdout.strip(),
                ],
                capture_output=True, text=True, check=True,
            )
            self.assertEqual(parsed.stdout.splitlines()[-1], "path:/nix/store/test-source#mac")


class SystemCheckSafetyTests(unittest.TestCase):
    def test_privacy_guard_blocks_external_reset(self):
        source = (REPOSITORY / "nix/darwin.nix").read_text()
        guard = re.search(r"privacyGuard = ''\n(.*?)\n  '';", source, re.S)
        self.assertIsNotNone(guard)
        self.assertIn("preActivation.text = lib.mkBefore privacyGuard", source)
        self.assertIn("${privacyGuard}\n    ${config.system.activationScripts.checks.text}", source)
        with tempfile.TemporaryDirectory(prefix="dotfiles-privacy-test-") as fixture:
            directory = Path(fixture)
            marker = directory / "external-reset"
            tool = directory / "tccutil"
            tool.write_text('#!/bin/sh\nprintf called > "$TEST_MARKER"\n')
            tool.chmod(0o755)
            environment = os.environ.copy()
            environment.update(PATH=str(directory), TEST_MARKER=str(marker))
            result = subprocess.run(
                ["/bin/bash", "-c", guard.group(1) + "\ntccutil reset SystemPolicyAppBundles"],
                env=environment, capture_output=True, text=True,
            )
            self.assertEqual(result.returncode, 2)
            self.assertIn("Grant the required permission in System Settings", result.stderr)
            self.assertFalse(marker.exists())


class LiveConfigTests(unittest.TestCase):
    def test_links_have_existing_sources(self):
        text = (REPOSITORY / "nix/links.nix").read_text()
        declarations = re.findall(r'"([^"\n]+)" = "((?:config|scripts)/[^"\n]+)";', text)
        links = dict(declarations)
        self.assertTrue(links)
        self.assertEqual(len(links), len(declarations), "Duplicate link targets")
        for target, source in links.items():
            with self.subTest(target=target):
                self.assertTrue((REPOSITORY / source).is_file())
                self.assertFalse(target.startswith((".pi/", ".agents/")))
        self.assertEqual(links[".config/pnpm/rc"], links["Library/Preferences/pnpm/rc"])
        neovim_targets = {
            target.removeprefix(".config/nvim/")
            for target in links
            if target.startswith(".config/nvim/")
        }
        neovim_files = {
            str(path.relative_to(REPOSITORY / "config/nvim"))
            for path in (REPOSITORY / "config/nvim").rglob("*")
            if path.is_file()
        }
        self.assertEqual(neovim_targets, neovim_files)

    def test_mise_has_no_global_tools(self):
        settings = tomllib.loads((REPOSITORY / "config/mise.toml").read_text())
        self.assertEqual(set(settings), {"settings"})
        self.assertEqual(settings["settings"]["minimum_release_age"], "7d")
        self.assertEqual(settings["settings"]["idiomatic_version_file_enable_tools"], ["rust"])

    def test_karabiner_uses_login_shells(self):
        settings = json.loads((REPOSITORY / "config/karabiner.json").read_text())
        commands = []
        for profile in settings["profiles"]:
            for rule in profile["complex_modifications"]["rules"]:
                for manipulator in rule["manipulators"]:
                    commands.extend(
                        action["shell_command"]
                        for action in manipulator.get("to", [])
                        if "shell_command" in action
                    )
        self.assertEqual(len(commands), 4)
        for command in commands:
            argv = shlex.split(command)
            self.assertEqual(argv[:2], ["/bin/zsh", "-lc"])
            self.assertTrue(argv[2].startswith('exec "$HOME/.local/bin/'))
            subprocess.run(["/bin/zsh", "-n", "-c", argv[2]], check=True)

    def test_login_shell_prefers_nix_profiles(self):
        with tempfile.TemporaryDirectory(prefix="dotfiles-zsh-test-") as home:
            bin_directory = Path(home) / "bin"
            bin_directory.mkdir()
            mise = bin_directory / "mise"
            mise.write_text("#!/bin/sh\nexit 0\n")
            mise.chmod(0o755)
            environment = os.environ.copy()
            environment.update(
                HOME=home,
                PATH=f"{home}/.pi/agent/bin:{home}/.local/share/mise/shims:{bin_directory}:/usr/bin:/bin",
                JAVA_HOME="/test/nix/zulu17",
                __HM_SESS_VARS_SOURCED="1",
            )
            command = '''
                mise() { print -r -- ':'; }
                source "$1"
                [[ $path[1] == /etc/profiles/per-user/andrei/bin ]] || exit 1
                [[ $path[2] == /run/current-system/sw/bin ]] || exit 2
                [[ $JAVA_HOME == /test/nix/zulu17 ]] || exit 3
                (( ! ${path[(Ie)$HOME/.pi/agent/bin]} )) || exit 4
                (( ! ${path[(Ie)$HOME/.local/share/mise/shims]} )) || exit 5
            '''
            result = subprocess.run(
                ["/bin/zsh", "-f", "-c", command, "zsh", str(REPOSITORY / "config/zsh/zprofile")],
                env=environment, capture_output=True, text=True,
            )
            self.assertEqual(result.returncode, 0, result.stderr)

    def test_mise_can_override_global_defaults(self):
        with tempfile.TemporaryDirectory(prefix="dotfiles-zsh-test-") as home:
            bin_directory = Path(home) / "bin"
            bin_directory.mkdir()
            mise = bin_directory / "mise"
            mise.write_text("#!/bin/sh\nexit 0\n")
            mise.chmod(0o755)
            environment = os.environ.copy()
            environment.update(HOME=home, PATH=f"{bin_directory}:/usr/bin:/bin")
            command = '''
                mise() { print -r -- 'export PATH="/test/project/bin:$PATH"'; }
                source "$1"
                [[ $path[1] == /test/project/bin ]]
            '''
            result = subprocess.run(
                ["/bin/zsh", "-f", "-c", command, "zsh", str(REPOSITORY / "config/zsh/zprofile")],
                env=environment, capture_output=True, text=True,
            )
            self.assertEqual(result.returncode, 0, result.stderr)

    def test_non_login_shell_preserves_project_path(self):
        # Do not read the user's private shell files or plugin state.
        with tempfile.TemporaryDirectory(prefix="dotfiles-zsh-test-") as home:
            environment = os.environ.copy()
            environment.update(HOME=home, PATH="/test/project/bin:/usr/bin:/bin")
            result = subprocess.run(
                [
                    "/bin/zsh", "-f", "-c",
                    'before=$PATH; source "$1"; [[ $PATH == "$before" ]]',
                    "zsh", str(REPOSITORY / "config/zsh/zshenv"),
                ],
                env=environment,
                capture_output=True,
                text=True,
            )
            self.assertEqual(result.returncode, 0, result.stderr)


if __name__ == "__main__":
    unittest.main()
