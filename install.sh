#!/bin/sh

if [ ! -d "$HOME/.yadr" ]; then
    echo "Installing YADR for the first time"
    git clone -b master --depth=1 https://github.com/podkovyrin/dotfiles.git "$HOME/.yadr"
    cd "$HOME/.yadr"
    rake install
else
    echo "YADR is already installed"
fi
