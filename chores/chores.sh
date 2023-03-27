#!/bin/sh

echo "🧹 Running chores (brew and gem updates, cleanup)"

sudo -v
# Keep-alive: update existing `sudo` time stamp until `chores` has finished
while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &

echo "🧹 brew"
brew update && brew upgrade && brew cleanup && brew doctor

echo "🧹 gem"
gem update && gem cleanup

echo "🧹 npm upgrade"
npm install -g @githubnext/github-copilot-cli

echo "🧹 cleanup"
CMM=$HOME/.yadr/clean_my_mac/clean_my_mac.sh
$CMM
sudo $CMM
