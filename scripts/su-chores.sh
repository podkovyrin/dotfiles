#!/bin/zsh

source "${HOME}/.zshrc"

echo "🧹 Running root chores: cleanup"

CMM=$HOME/.dotfiles/scripts/clean_my_mac/clean_my_mac.sh
sudo $CMM
