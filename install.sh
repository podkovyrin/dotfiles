#!/bin/sh

if [ ! -d "$HOME/.dotfiles" ]; then
    echo "Installing dotfiles for the first time"

    if ! xcode-select -p &>/dev/null; then
        echo "Installing Xcode Command Line Tools..."
        xcode-select --install
        # wait until the Xcode Command Line Tools are installed
        until xcode-select -p &>/dev/null; do
            sleep 5
        done
        echo "Xcode Command Line Tools installed."
    else
        echo "Xcode Command Line Tools already installed."
    fi

    git clone https://github.com/podkovyrin/dotfiles.git "$HOME/.dotfiles"
    cd "$HOME/.dotfiles"

    git remote remove origin
    git remote add origin git@github.com:podkovyrin/dotfiles.git
    git branch --set-upstream-to origin/master

    echo
    echo "To continue, run ./setup-main.sh"
else
    echo "dotfiles is already installed"
fi
