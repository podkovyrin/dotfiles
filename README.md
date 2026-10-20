# Andrei's Mac configuration

nix-darwin + Home Manager + Homebrew for one Apple Silicon Mac.

## Usage

The tools come from three sources. `./n` uses these words everywhere:

| Source | Config | For |
|---|---|---|
| `nix` | `nix/packages.txt`, `nix/flake.lock` | stable CLIs |
| `brew` | `nix/casks.txt`, `nix/brews.txt`, `masApps` in `nix/homebrew.nix` | macOS apps, a few formulae, App Store apps |
| `mise` | `config/mise.toml` | runtimes and fast-moving CLIs |

The `.txt` lists have one name per line and `#` comments. Edit them by hand or
with `./n add` and `./n remove`, which append and delete lines. Packages that
need a Nix expression go in `nix/packages.nix`.

Edit files in `config/` directly; no rebuild needed. After editing `nix/`
or `config/mise.toml`:

```sh
./n apply                # apply the config: Nix, Homebrew, and mise
./n apply -n             # build and show the changes only

./n upgrade              # new releases from all sources: one plan, one confirm
./n upgrade -n           # show what is outdated
./n upgrade mise         # one source: nix, brew, mise, or a flake input (nixpkgs)

./n add <tool>…          # select the source, confirm, add, apply
./n remove <tool>…       # remove from the config that declares it, apply
./n info <tool>…         # where it is declared, its command, its sources
./n list [source]        # the declared tools

./n history              # what the last apply changed
./n rollback             # previous Nix generation (Homebrew and mise stay)
./n clean [age]          # old generations (default 14d), downloads, mise versions
```

## Adding a tool

Use `./n add <tool>`, also when a tool's README says `brew install`,
`npm i -g`, or `pnpm add -g`. It looks the name up in all sources and
selects one in this order:

1. A Homebrew cask that installs a macOS app: `nix/casks.txt`.
2. Nixpkgs, when its release is not older than mise's: `nix/packages.txt`.
3. The mise registry (no asdf or vfox plugins): `config/mise.toml`.
4. A Homebrew formula, or a cask with only a command: `nix/brews.txt`,
   `nix/casks.txt`.

```
$ ./n add -n hk
hk: mise:hk -> config/mise.toml (Nixpkgs has the older 2.0.1)
    nix:hk      2.0.1    Tool for managing git hooks
  ✓ mise:hk     2.6.0
    brew:hk     2.7.1    Git hook and pre-commit lint manager
```

Each line is a name that you can type to select that source. Use the prefix
that matches the install line in the tool's README:

| README says | Type |
|---|---|
| `brew install x` | `./n add brew:x` (the formula, else the cask) |
| `brew install --cask x` | `./n add cask:x` |
| `npm i -g x` | `./n add npm:x` |
| `pipx install x`, `uv tool install x` | `./n add pipx:x` |
| `cargo install x`, `go install x` | `./n add cargo:x`, `./n add go:x` |

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

`./n apply` installs what the config declares. It does not upgrade.
`./n upgrade` checks all sources and shows one plan:

- `nix`: updates `nix/flake.lock`, then shows the package changes. If you
  do not confirm, the lock file is restored. Commit it after an upgrade.
- `brew`: the outdated formulae and casks. App Store apps update through
  the App Store.
- `mise`: new releases wait 7 days; the tools with `minimum_release_age`
  in `config/mise.toml` wait 1 day.

## New Mac

```sh
bash -c "$(curl -fsSL https://raw.githubusercontent.com/podkovyrin/dotfiles/master/scripts/setup)"
```

If it stops, fix the problem and run the same command again. Then restore
`~/.ssh` and `~/.gnupg` from backup, and use `./n apply` from then on.
