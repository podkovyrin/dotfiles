# Andrei's Mac configuration

nix-darwin + Home Manager + Homebrew for one Apple Silicon Mac.

## Usage

Edit files in `config/` directly; no rebuild needed. After editing `nix/`:

```sh
./n switch           # build and activate
./n build            # build only, into .build/system
./n diff             # build and compare packages with the active system
./n update [input…]  # update inputs, diff, confirm, switch
./n brew             # upgrade Homebrew casks and App Store apps
./n tools            # install and upgrade global mise tools (Pi)
./n rollback         # activate the previous generation
./n gc [age]         # delete generations older than age (default 14d)
```

`./apply --dry-run` also previews Homebrew removals.

## Updating

Builds only change when `nix/flake.lock` changes.

- Some tools are pinned to release tags in `nix/flake.nix`. Change
  the tag, then `./n update <input>`.
- `./n switch` does not upgrade Homebrew apps. Use `./n brew`.
- Pi and other fast-moving npm CLIs are in `config/mise.toml`, not Nix.
  Update them with `./n tools`.

## New Mac

```sh
bash -c "$(curl -fsSL https://raw.githubusercontent.com/podkovyrin/dotfiles/master/apply)"
```

Restore `~/.ssh` and `~/.gnupg` from backup.
