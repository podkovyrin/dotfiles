#!/usr/bin/env bash

# Install command-line tools using Homebrew.

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

brew install ruby
brew install python3

# Install MacAppStore console
brew install mas

# Remove outdated versions from the cellar.
brew cleanup
