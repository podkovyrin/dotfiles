#!/bin/sh

# Install command-line tools using Homebrew.

brew || /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"

# Make sure we’re using the latest Homebrew.
brew update

# Upgrade any already-installed formulae.
brew upgrade

brew install ruby
brew install python3

# Install GnuPG to enable PGP-signing commits.
brew install gnupg

brew install git
brew install git-lfs
brew install tig
brew install hub
brew install mercurial
brew install cmake
brew install colordiff
brew install clang-format
brew install swiftformat
brew install swiftlint
brew install bartycrouch
brew install tldr

# Install MacAppStore console
brew install mas

# Install GUI Apps

brew cask install iterm2
brew cask install google-chrome
brew cask install sublime-text
brew cask install sublime-merge
brew cask install 1password
brew cask install slack
brew cask install sourcetree
brew cask install spotify
brew cask install the-unarchiver
brew cask install vlc
brew cask install macmediakeyforwarder
brew cask install skype
brew cask install telegram
brew cask install opensim
brew cask install transmission
brew cask install wwdc
brew cask install nrlquaker-winbox
brew cask install reveal
brew cask install google-backup-and-sync
brew cask install charles
brew cask install postman
brew cask install sf-symbols
brew cask install pock

# Don't forget to install manually:
# Magnet (AppStore)

# Remove outdated versions from the cellar.
brew cleanup

gem install cocoapods
gem install fastlane

