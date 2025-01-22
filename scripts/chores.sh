#!/bin/zsh

source "${HOME}/.zshrc"

echo "🧹 Running chores (brew and gem updates, cleanup)"

# sudo -v
# # Keep-alive: update existing `sudo` time stamp until `chores` has finished
# while true; do sudo -n true; sleep 30; kill -0 "$$" || exit; done 2>/dev/null &

echo "🧹 brew"
brew update && brew upgrade && brew cleanup && brew doctor && brew autoremove

echo "🧹 gem"
gem update && gem cleanup

echo "🧹 shell"
zimfw update

echo "🧹 cleanup"
CMM=$HOME/.dotfiles/scripts/clean_my_mac/clean_my_mac.sh
$CMM
sudo $CMM

exec zsh
