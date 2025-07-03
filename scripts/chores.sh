#!/bin/zsh

source "${HOME}/.zshrc"

echo "🧹 Running chores (brew and gem updates, cleanup)"

echo "🧹 brew"
brew update && brew upgrade && brew cleanup && brew doctor && brew autoremove

# echo "🧹 gem"
# gem update && gem cleanup

echo "🧹 shell"
zimfw upgrade
zimfw update

echo "🧹 cleanup"
CMM=$HOME/.dotfiles/scripts/clean_my_mac/clean_my_mac.sh
$CMM

exec zsh
