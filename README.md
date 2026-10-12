# Andrei's Mac configuration

nix-darwin + Home Manager + Homebrew for one Apple Silicon Mac.

## Usage

Edit files in `config/` directly; no rebuild needed. After editing `nix/`:

```sh
./n switch           # build and activate
./n build            # build only, into .build/system
./n diff             # build and compare packages with the active system
./n update [input…]  # update inputs, diff, confirm, switch
./n rollback         # activate the previous generation
./n gc [age]         # delete generations older than age (default 14d)
```

`./apply --dry-run` also previews Homebrew removals.

## Updating

Builds only change when `nix/flake.lock` changes.

- Some tools are pinned to release tags in `nix/flake.nix`. Change
  the tag, then `./n update <input>`.

## New Mac

```sh
bash -c "$(curl -fsSL https://raw.githubusercontent.com/podkovyrin/dotfiles/master/apply)"
```

Restore `~/.ssh` and `~/.gnupg` from backup.
