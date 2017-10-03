#!/usr/bin/env bash

# Install command-line tools using Homebrew.

# Make sure we’re using the latest Homebrew.
brew update

# Upgrade any already-installed formulae.
brew upgrade

brew install bash-completion

# Install GnuPG to enable PGP-signing commits.
brew install gnupg

# Install more recent versions of some macOS tools.
brew install vim --with-override-system-vi

brew install git
brew install git-lfs
brew install tig
brew install hub

# Install Node.js. Note: this installs `npm` too, using the recommended
# installation method.
brew install node

# Install MacAppStore console
brew install mas

# Install JSON hacking tool (depends on Node.js)
npm install -g underscore-cli

# Remove outdated versions from the cellar.
brew cleanup
