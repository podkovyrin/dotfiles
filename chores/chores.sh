#!/bin/sh

echo "🧹 Running chores (brew & gem update, cleanup)"

sudo -v

echo "🧹 brew"
brew update && brew upgrade && brew cleanup && brew doctor

echo "🧹 gem"
gem update && gem cleanup

echo "🧹 cleanup"

../clean_my_mac/clean_my_mac.sh

sudo ../clean_my_mac/clean_my_mac.sh
