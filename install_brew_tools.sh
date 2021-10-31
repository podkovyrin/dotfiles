#!/bin/sh

# Install command-line tools using Homebrew.

brew || /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"

# Make sure we’re using the latest Homebrew.
brew update

# Upgrade any already-installed formulae.
brew upgrade

# brew install ruby
# brew install python3

# Install GnuPG to enable PGP-signing commits.
brew install gnupg

brew install git
brew install git-lfs
brew install tig
brew install hub
# brew install github/gh/gh
brew install mercurial
brew install cmake
brew install colordiff
brew install clang-format
# brew install swiftformat
# brew install swiftlint
brew install bartycrouch
brew install tldr
brew install carthage
# brew install svn

# Install MacAppStore console
brew install mas

# Install GUI Apps

brew install iterm2
brew install sublime-text
brew install slack
brew install fork
brew install spotify
brew install the-unarchiver
brew install vlc
brew install macmediakeyforwarder
brew install skype
brew install telegram
brew install opensim
# brew install transmission
brew install wwdc
brew install nrlquaker-winbox
# brew install reveal
# brew install charles
brew install sf-symbols
brew install chrome
# brew install exodus
brew install db-browser-for-sqlite

# Fonts

brew tap homebrew/cask-fonts
brew install font-montserrat
brew install font-jetbrains-mono

# Remove outdated versions from the cellar.
brew cleanup

# Fix Catalina compatibility

xattr -cr /Applications/MacMediaKeyForwarder.app
