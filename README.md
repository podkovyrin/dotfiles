# Andrei's Mac configuration

My tools and settings for one Apple Silicon Mac, on top of
[dotkit](https://github.com/podkovyrin/dotkit) (`~/.dotkit`). dotkit is the
shared base: nix-darwin, Home Manager, Homebrew, zsh, Git, Ghostty, herdr,
Starship, the common tools, and the `dotkit` command (from any directory; `./dotkit`
here before the first apply). Its README explains how a base setting is
changed here.

`config/zsh/zprofile` sets `DOTKIT_DIR=~/.dotkit`, so `dotkit` builds with the
checkout, and `nix/home.nix` links the base config files to it
(`dotkit.liveDir`). Edits in `~/.dotkit` apply here first; commit and push
them to release them to everyone.

## Usage

The tools come from three sources. `dotkit` uses these words everywhere:

| Source | Config | For |
|---|---|---|
| `nix` | `nix/packages.txt`, `nix/flake.lock` (dotkit, which pins Nixpkgs) | stable CLIs |
| `brew` | `nix/casks.txt`, `nix/brews.txt`, `homebrew.masApps` in `nix/darwin.nix` | macOS apps, a few formulae, App Store apps |
| `mise` | `config/mise.toml` (the runtimes are in dotkit) | runtimes and fast-moving CLIs |

The `.txt` lists have one name per line and `#` comments. Edit them by hand or
with `dotkit add` and `dotkit remove`, which append and delete lines. They come
after the dotkit lists of the same names. Packages that need a Nix
expression go in `home.packages` in `nix/home.nix`.

Edit files in `config/` directly; no rebuild needed. After editing `nix/`
or `config/mise.toml`:

```sh
dotkit apply             # apply the config: Nix, Homebrew, and mise
dotkit apply -n          # build and show the changes only

dotkit upgrade           # new releases from all sources: one plan, one confirm
dotkit upgrade -n        # show what is outdated
dotkit upgrade mise      # one source: nix, brew, mise, or a flake input (nixpkgs)

dotkit add <tool>…       # select the source, confirm, add, apply
dotkit remove <tool>…    # remove from the config that declares it, apply
dotkit info <tool>…      # where it is declared, its command, its sources
dotkit list [source]     # the declared tools

dotkit history           # what the last apply changed
dotkit rollback          # previous Nix generation (Homebrew and mise stay)
dotkit clean [age]       # old generations (default 14d), downloads, mise versions
```

## Adding a tool

Use `dotkit add <tool>`, also when a tool's README says `brew install`,
`npm i -g`, or `pnpm add -g`. It looks the name up in all sources and
selects one in this order:

1. A Homebrew cask that installs a macOS app: `nix/casks.txt`.
2. Nixpkgs, when its release is not older than mise's: `nix/packages.txt`.
3. The mise registry (no asdf or vfox plugins): `config/mise.toml`.
4. A Homebrew formula, or a cask with only a command: `nix/brews.txt`,
   `nix/casks.txt`.

```
$ dotkit add -n hk
hk: mise:hk -> config/mise.toml (Nixpkgs has the older 2.0.1)
    nix:hk      2.0.1    Tool for managing git hooks
  ✓ mise:hk     2.6.0
    brew:hk     2.7.1    Git hook and pre-commit lint manager
```

Each line is a name that you can type to select that source. Use the prefix
that matches the install line in the tool's README:

| README says | Type |
|---|---|
| `brew install x` | `dotkit add brew:x` (the formula, else the cask) |
| `brew install --cask x` | `dotkit add cask:x` |
| `npm i -g x` | `dotkit add npm:x` |
| `pipx install x`, `uv tool install x` | `dotkit add pipx:x` |
| `cargo install x`, `go install x` | `dotkit add cargo:x`, `dotkit add go:x` |

`nix:` and `mise:` select Nixpkgs and the mise registry. Any other mise
backend (`github:`, `aqua:`, …) also works. For a one-off run, use `npx` or
`uvx` instead.

A bare name does not select npm or PyPI, because anyone can publish any
name there. Check the package in the list, then type its name. A scoped npm
name (`@scope/pkg`) needs no prefix.

`add` stops when a global tool already supplies the command (for example
`rg` from `ripgrep`); `-f` adds the tool anyway. Nix changes are built and
applied first. If the build fails, the Nix files are restored and mise is
not changed.

## Upgrading

`dotkit apply` installs what the config declares. It does not upgrade.
`dotkit upgrade` checks all sources and shows one plan:

- `nix`: updates `nix/flake.lock` (the dotkit release) and, with
  `DOTKIT_DIR`, `~/dotkit/flake.lock` (Nixpkgs and the other inputs), then
  shows the package changes. If you do not confirm, the lock files are
  restored. Commit them after an upgrade.
- `brew`: the outdated formulae and casks. App Store apps update through
  the App Store.
- `mise`: new releases wait 7 days (a dotkit setting); the tools with
  `minimum_release_age` in `config/mise.toml` wait 1 day.

## New Mac

```sh
xcode-select --install    # for git; wait for the installer to finish
git clone https://github.com/podkovyrin/dotkit.git ~/.dotkit
DOTKIT_DIR=~/.dotkit ~/.dotkit/scripts/setup https://github.com/podkovyrin/dotfiles.git
```

If it stops, fix the problem and run the same command again. Then restore
`~/.ssh` and `~/.gnupg` from backup, and use `dotkit apply` from then on.
