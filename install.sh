#!/bin/sh

set -eu

if [ ! -d "$HOME/.dotfiles" ]; then
    echo "Installing dotfiles for the first time"

    case $(uname -s) in
        Darwin)
            if ! xcode-select -p >/dev/null 2>&1; then
                echo "Installing Xcode Command Line Tools..."
                xcode-select --install
                # Wait until the tools, including Git, are available.
                until xcode-select -p >/dev/null 2>&1; do
                    sleep 5
                done
                echo "Xcode Command Line Tools installed."
            else
                echo "Xcode Command Line Tools already installed."
            fi
            ;;
        Linux)
            if ! command -v git >/dev/null 2>&1; then
                echo "Git is required. On Omarchy, install it with: omarchy pkg add git" >&2
                exit 1
            fi
            ;;
        *)
            echo "Unsupported operating system: $(uname -s)" >&2
            exit 1
            ;;
    esac

    git clone https://github.com/podkovyrin/dotfiles.git "$HOME/.dotfiles"
    cd "$HOME/.dotfiles"

    git remote set-url origin git@github.com:podkovyrin/dotfiles.git
    git branch --set-upstream-to origin/master

    echo
    echo "To continue, run ~/.dotfiles/setup-main.sh"
else
    echo "dotfiles is already installed"
fi
