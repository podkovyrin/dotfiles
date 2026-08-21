# podkovyrin’s dotfiles

## Installation

```sh
sh -c "`curl -fsSL https://raw.githubusercontent.com/podkovyrin/dotfiles/master/install.sh`"
```

`setup-main.sh` selects the platform-specific setup automatically:

- macOS uses Homebrew and links the complete workstation configuration.
- Omarchy Linux links only the portable subset and leaves Omarchy-managed Bash,
  Neovim, tmux, terminal, btop, LazyGit, and desktop configs untouched.

The Linux setup never invokes Homebrew. It uses `omarchy pkg add` only when GNU
Stow or mise is missing, then lets mise install the declared language runtimes.
Tools already supplied by Omarchy as lazy stubs, such as `gh`, Claude, Codex,
and Pi, are marked macOS-only in the mise config.
