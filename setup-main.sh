#!/bin/sh

###############################################################################
# General configs

echo
echo "➡️ Setting up general configs..."

install_dir() {
    for src in "$1"/*; do
        install_link "$src"
    done
}

install_link() {
    if [ -e "$1" ]; then
        full_source=$(pwd)/$1
        file=$(basename "$1")
        target="$HOME/.$file"

        echo "Set: '${full_source}' -> '${target}'"
        
        # Backup and copy
        if [ -e "$target" ]; then
            backup_target="${target}.backup"
            echo "[Overwriting] '${target}'. Leaving original at '${backup_target}'"
            mv "$target" "$backup_target"
        fi

        ln -nfs "$full_source" "$target"
    fi
}

install_dir "git"
install_dir "ruby"
install_dir "vimify"
install_link "vim"

###############################################################################
# Package manager

echo
echo "➡️ Setting up brew..."

install_brew() {
    # Install command-line tools using Homebrew.

    brew || /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

    # Make sure we’re using the latest Homebrew.
    brew update

    # Upgrade any already-installed formulae.
    brew upgrade
}

install_brew

###############################################################################
# Fish shell

echo
echo "➡️ Setting up Fish shell..."

brew install fish

install_fish_config() {
    for src in $(pwd)/fish/*; do
        file=$(basename "${src}")
        target="$HOME/.config/fish/$file"

        echo "Set: '${src}' -> '${target}'"

        if [ -e "$target" ]; then
            rm -rf "$target"
        fi

        ln -nfs "$src" "$target"
    done
}

install_fish_config

install_fish_shell() {
    # Check if Fish is installed at /opt/homebrew/bin/fish
    if [ -f "/opt/homebrew/bin/fish" ]; then
        echo "Fish shell found at /opt/homebrew/bin/fish"

        # Check if Fish is already in the list of standard shells
        if ! grep -q "/opt/homebrew/bin/fish" /etc/shells; then
            echo "Adding Fish to the list of standard shells."
            echo "/opt/homebrew/bin/fish" | sudo tee -a /etc/shells > /dev/null
        fi

        # Check if the current shell is already Fish
        if [ "$SHELL" = "/opt/homebrew/bin/fish" ]; then
            echo "Fish is already the default shell."
        else
            echo "Changing the default shell to Fish"
            chsh -s /opt/homebrew/bin/fish
        fi
    else
        echo "Fish shell not found at /opt/homebrew/bin/fish. Please install Fish and try again."
    fi
}

install_fish_shell

install_fish_plugins() {
    /opt/homebrew/bin/fish

    curl -sL https://raw.githubusercontent.com/jorgebucaran/fisher/main/functions/fisher.fish | source && fisher install jorgebucaran/fisher
    fisher install jorgebucaran/nvm.fish

    exit
}

install_fish_plugins

echo
echo "✅ dotfiles has been installed. Please restart your terminal."
