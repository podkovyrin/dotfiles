#!/usr/bin/env bash

# Install command-line tools using Homebrew.

brew || /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"

# Make sure we’re using the latest Homebrew.
brew update

# Upgrade any already-installed formulae.
brew upgrade

brew install bash-completion

# Install GnuPG to enable PGP-signing commits.
brew install gnupg

brew install git
brew install git-lfs
brew install tig
brew install hub
brew install wget
brew install mercurial

brew install ruby
brew install python3

brew install tldr

# Install MacAppStore console
brew install mas

# Install GUI Apps

brew cask install iterm2
brew cask install google-chrome
brew cask install sublime-text
brew cask install 1password
brew cask install dropbox
brew cask install slack
brew cask install sourcetree
brew cask install spotify
brew cask install the-unarchiver
brew cask install vlc

# Don't forget to install manually:
# HighSierraMediaKeyEnabler
# Magnet (AppStore)

# Remove outdated versions from the cellar.
brew cleanup
