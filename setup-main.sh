#!/bin/sh

###############################################################################
# Helpers

link_file() {
    local src=$1
    local target=$2

    echo "Set: '${src}' -> '${target}'"
    
    if [ -e "$target" ]; then
        rm -rf "$target"
    fi

    ln -nfs "$src" "$target"
}

###############################################################################
# General configs

echo
echo "➡️ Setting up general configs..."

install_dot_configs() {
    for src in $(pwd)/dot/*; do
        local target="$HOME/.$(basename "$src")"
        link_file "$src" "$target"
    done
}

install_dot_configs

###############################################################################
# Fish shell

echo
echo "➡️ Setting up Fish shell..."

install_fish() {
    if [ ! -f "/opt/homebrew/bin/fish" ]; then
        brew install fish
    fi

    if [ ! -f "/opt/homebrew/bin/starship" ]; then
        brew install starship
    fi

    # Fish config

    for src in $(pwd)/config/fish/*; do
        local target="$HOME/.config/fish/$(basename "${src}")"
        link_file "$src" "$target"
    done

    # Set fish as default shell

    if [ -f "/opt/homebrew/bin/fish" ]; then
        echo "Fish shell found at /opt/homebrew/bin/fish"

        if ! grep -q "/opt/homebrew/bin/fish" /etc/shells; then
            echo "Adding Fish to the list of standard shells."
            echo "/opt/homebrew/bin/fish" | sudo tee -a /etc/shells > /dev/null
        fi

        if [ "$SHELL" = "/opt/homebrew/bin/fish" ]; then
            echo "Fish is already the default shell."
        else
            echo "Changing the default shell to Fish"
            chsh -s /opt/homebrew/bin/fish
        fi
    else
        echo "Fish shell not found at /opt/homebrew/bin/fish. Please install Fish and try again."
    fi

    # Fish plugins

    fish -c 'curl -sL https://raw.githubusercontent.com/jorgebucaran/fisher/main/functions/fisher.fish | source && fisher install jorgebucaran/fisher'
    fish -c 'fisher install jorgebucaran/nvm.fish'
    fish -c 'fisher install oh-my-fish/plugin-foreign-env'

    # Misc

    link_file "$(pwd)/config/starship.toml" "$HOME/.config/starship.toml"
    link_file "$(pwd)/config/gitui" "$HOME/.config/gitui"
    
    # Disable Last Login Message
    touch $HOME/.hushlogin 
}

install_fish

echo
echo "Please restart your terminal."
