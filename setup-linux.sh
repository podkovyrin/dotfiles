#!/bin/sh

set -eu

script_dir=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)

if ! command -v omarchy >/dev/null 2>&1; then
    echo "This setup currently supports Linux through Omarchy." >&2
    exit 1
fi

if ! command -v stow >/dev/null 2>&1; then
    echo "Installing GNU Stow through Omarchy..."
    omarchy pkg add stow
fi

if ! command -v mise >/dev/null 2>&1; then
    echo "Installing mise through Omarchy..."
    omarchy pkg add mise
fi

# Keep this deliberately small. Omarchy continues to own Bash, Neovim, tmux,
# terminal, btop, LazyGit, and desktop configuration.
portable_packages="editorconfig editrc gem git mise npmrc pnpm uv yarn bun herdr"

echo "Linking portable dotfiles..."
for package in $portable_packages; do
    stow --dir "$script_dir" --target "$HOME" --restow --no-folding "$package"
done

# Add the Herdr hook after Omarchy initializes its Bash prompt.
herdr_bash_hook='[[ -r ~/.config/herdr/process-name.bash ]] && source ~/.config/herdr/process-name.bash'
if ! rg -Fqx "$herdr_bash_hook" "$HOME/.bashrc" 2>/dev/null; then
    printf '\n%s\n' "$herdr_bash_hook" >> "$HOME/.bashrc"
fi

# Omarchy already provides and activates mise. This installs only the tools in
# our fragment; entries marked macOS-only are skipped natively by mise.
mise install

echo "Linux dotfiles setup complete. Omarchy-managed configs were left intact."
