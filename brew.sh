#!/usr/bin/env bash

# Install command-line tools using Homebrew.

# Make sure we’re using the latest Homebrew.
brew update

# Upgrade any already-installed formulae.
brew upgrade

# Install Bash 4.
# Note: don’t forget to add `/usr/local/bin/bash` to `/etc/shells` before
# running `chsh`.
brew install bash
brew install bash-completion

# Switch to using brew-installed bash as default shell
if ! fgrep -q '/usr/local/bin/bash' /etc/shells; then
  echo '/usr/local/bin/bash' | sudo tee -a /etc/shells;
  chsh -s /usr/local/bin/bash;
fi;

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
