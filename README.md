# podkovyrin’s dotfiles

## Dotfiles

### Installation

```sh
sh -c "`curl -fsSL https://raw.githubusercontent.com/podkovyrin/dotfiles/master/install.sh`"
```

`setup-main.sh` selects the platform-specific setup automatically:

- macOS uses Homebrew and links the complete workstation configuration.
- Omarchy Linux links only the portable subset and leaves Omarchy-managed Bash,
  Neovim, tmux, terminal, btop, LazyGit, and desktop configs untouched.

The Linux setup never invokes Homebrew. It uses `omarchy pkg add` only when GNU
Stow or mise is missing, then lets mise install the declared language runtimes.
Tools already supplied by Omarchy as lazy stubs, such as `gh`, Claude, and Codex,
are marked macOS-only in the mise config. Linux also uses Omarchy's Pi stub.

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
│   ├── agents/
│   └── extensions/
└── agents/.agents/       # -> ~/.agents
    ├── .skill-lock.json
    └── skills/
```

- Stow links config files and whole skill and extension directories into `$HOME`.
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
