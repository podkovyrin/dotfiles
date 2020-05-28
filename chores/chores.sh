#!/bin/sh

echo "🧹 Running chores (brew & gem update, cleanup)"

sudo -v

echo "🧹 brew"
brew update && brew upgrade && brew cleanup && brew doctor

echo "🧹 gem"
gem update && gem cleanup

echo "🧹 cleanup"

$yadr/clean_my_mac/clean_my_mac.sh

sudo $yadr/clean_my_mac/clean_my_mac.sh
