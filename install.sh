#!/bin/sh

if [ ! -d "$HOME/.dotfiles" ]; then
    echo "Installing dotfiles for the first time"
    git clone https://github.com/podkovyrin/dotfiles.git "$HOME/.dotfiles"
    cd "$HOME/.dotfiles"

    git remote remove origin
    git remote add origin git@github.com:podkovyrin/dotfiles.git
    git branch --set-upstream-to origin/master
else
    echo "dotfiles is already installed"
fi
