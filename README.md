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

[pi](https://pi.dev) config and agent skills live in `agentfiles/`. They are
installed separately from the dotfiles, with their own script
(`agentfiles/setup.sh`). The dotfiles setup does not use or link them.
GNU Stow links each package into `$HOME`.

### Layout

```
~/.dotfiles/agentfiles/
├── setup.sh                  # stow all packages, configure git filter
├── pi/.pi/agent/             # -> ~/.pi/agent
│   ├── settings.json
│   ├── cloak.json
│   ├── agents/               # subagent definitions (pi-interactive-subagents)
│   └── extensions/
└── agents/.agents/           # -> ~/.agents (shared by pi, Codex, Cursor, ...)
    ├── .skill-lock.json      # sources of installed skills (npx skills)
    └── skills/
```

To add a package, create `<name>/` with the same paths as under `$HOME`, add the
name to `packages` in `setup.sh`, and run it again.

### Install on a new machine

Install pi, then:

```sh
git clone git@github.com:podkovyrin/dotfiles.git ~/.dotfiles   # skip if already cloned
~/.dotfiles/agentfiles/setup.sh
pi update --extensions   # install the packages listed in settings.json
pi                       # then /login
```

`setup.sh` needs `stow` and `jq`. If `~/.pi/agent/settings.json` or other target
files already exist, stow stops with a conflict. Move those files away and run
the script again.

`setup.sh` creates `~/.pi/agent` and `~/.agents` as real directories before it
stows. Inside them, stow links whole directories (`skills/`, `extensions/`,
`agents/`) to this repo, so new files in those directories appear in `git status`.

### Skills

Skills are stored in the repo, so a new machine gets them with no download.
`.skill-lock.json` records the source of each skill that came from a repo. The
[`skills`](https://skills.sh) CLI reads and writes it at `~/.agents/.skill-lock.json`.
The CLI writes through the stow links, so updates appear as git diffs.

```sh
npx skills ls -g                                # list global skills and sources
npx skills update -g                            # update skills from the lock
npx skills add owner/repo -g -s <skill>         # install and add to the lock
npx skills remove -g <skill>
```

Do not set `XDG_STATE_HOME`. If it is set, the CLI uses
`$XDG_STATE_HOME/skills/.skill-lock.json` and does not see this lock.

| Skill            | Source                                   | Update             |
| ---------------- | ---------------------------------------- | ------------------ |
| `bro`            | `backnotprop/bro`                        | `npx skills update` |
| `cli-guidelines` | local, based on [clig.dev](https://clig.dev) | edit in place  |
| `ste-writing`    | local, based on ASD-STE100 Issue 8       | edit in place      |
| `unslop`         | local edit of `backnotprop/pstack` `unslop` | edit in place   |
| `cua-driver`     | cua-driver installer (not tracked)       | update cua-driver  |
| `hunk-review`    | copy of the skill bundled with `hunk`    | copy again (below) |

`unslop` has local changes. If you add it to the lock, `npx skills update`
replaces the local changes with the upstream version.

The cua-driver installer links `~/.agents/skills/cua-driver` to
`~/.cua-driver/skills/cua-driver` and keeps it at the version of the binary.
That link is in the repo directory but git ignores it.

`hunk-review` is a copy of the skill that ships with the
[Hunk](https://github.com/modem-dev/hunk) CLI. It is a copy and not a link,
because the bundled path contains the Hunk version and the next update breaks
a link to it. Copy the skill again after each Hunk update (`mise upgrade hunk`
or `hunk update`):

```sh
cp "$(hunk skill path)" ~/.dotfiles/agentfiles/agents/.agents/skills/hunk-review/SKILL.md
git -C ~/.dotfiles diff --stat agentfiles   # no diff means the skill did not change
```

Do not edit this copy. The next update replaces local changes.

### What is not tracked

Pi writes state and secrets to real files in `~/.pi/agent`, outside this repo:
`auth.json`, `telegram.json`, `trust.json`, `models-store.json`, `sessions/`,
`handoffs/`, `install/`, `bin/`, `npm/`, `git/`. Set these up on each machine:

- `auth.json`: run `/login`, or set provider env vars.
- `telegram.json`: pi-telegram bot setup.
- `trust.json`: trusted project paths.

`settings.json` contains machine IDs. The `pi-settings` git filter (set by
`setup.sh`) removes `deviceId`, `trackingId`, and `lastChangelogVersion` before
git stores the file.

To track `AGENTS.md`, `keybindings.json`, `prompts/`, or `themes/`, move them to
`pi/.pi/agent/` and run `setup.sh`. Track `models.json` or `mcp.json` only if each
secret is an env reference (`$NAME`) or a `!command`, not a literal key.
