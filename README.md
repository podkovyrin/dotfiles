# podkovyrin’s dotfiles

## Dotfiles

### Installation

```sh
sh -c "`curl -fsSL https://raw.githubusercontent.com/podkovyrin/dotfiles/master/install.sh`"
```

`setup-main.sh` selects the platform-specific setup automatically:

- macOS installs Homebrew packages from `Brewfile` and links the complete
  workstation configuration.
- Omarchy Linux links only the portable subset and leaves Omarchy-managed Bash,
  Neovim, tmux, terminal, btop, LazyGit, and desktop configs untouched.

The Linux setup never invokes Homebrew. It uses `omarchy pkg add` only when GNU
Stow or mise is missing, then lets mise install the declared language runtimes.
Tools already supplied by Omarchy as lazy stubs, such as `gh`, Claude, and Codex,
are marked macOS-only in the mise config. Linux also uses Omarchy's Pi stub.

### Homebrew

`Brewfile` lists the taps, formulae, casks, and Mac App Store apps, grouped by
section. mise manages the Go, Cargo, and npm tools, so the Brewfile does not
list them. Edit the file by hand when you install or remove a package. Do not
use `brew bundle dump`, because it rewrites the file and removes the sections.

- `brewcheck` lists entries that are not installed. It ignores outdated
  packages, because [upgate](https://github.com/podkovyrin/upgate) does the
  upgrades.
- `brewextra` lists installed packages that the Brewfile does not have. It is
  a dry run. Add `--force` to uninstall them.

## Agent files

[Pi](https://pi.dev) config and shared skills live in `agentfiles/`.
Install them separately from the main dotfiles setup. Requires `stow` and `jq`.

```sh
~/.dotfiles/agentfiles/setup.sh
pi update --extensions
pi                       # then /login
```

Move conflicting target files aside before running setup.

### Layout

```text
agentfiles/
├── setup.sh
├── pi/.pi/agent/         # -> ~/.pi/agent
│   ├── settings.json
│   ├── cloak.json
│   ├── open-tui.json
│   └── extensions/
├── agents/.agents/       # -> ~/.agents
│   ├── .skill-lock.json
│   └── skills/
└── copied/               # copied, not linked
    └── pi-subagent-manager/settings.json  # -> ~/.pi/agent/subagent-manager/
```

- Stow links config files and whole skill and extension directories into `$HOME`.
- `setup.sh` copies the files in `copied/` because their tools reject symlinks.
  If you change settings in `/agents`, copy the file back into the repo.
- State and secrets stay outside the repo.
- The settings git filter strips machine IDs and the changelog version.

### Skills

```sh
npx skills ls -g
npx skills update -g
npx skills add owner/repo -g -s <skill>
npx skills remove -g <skill>
```

- Leave `XDG_STATE_HOME` unset so the CLI uses `~/.agents/.skill-lock.json`.
- `cli-guidelines`, `ste-writing`, and `unslop` have local edits. Do not overwrite them with upstream updates.
- `cua-driver` is installer-managed and not tracked.
- Refresh `hunk-review` after each Hunk update:

```sh
cp "$(hunk skill path)" ~/.dotfiles/agentfiles/agents/.agents/skills/hunk-review/SKILL.md
```
