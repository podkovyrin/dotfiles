#!/bin/sh

# Install command-line tools using Homebrew.

brew || /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"

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
brew install github/gh/gh
brew install mercurial
brew install cmake
brew install colordiff
brew install clang-format
brew install swiftformat
brew install swiftlint
brew install bartycrouch
brew install tldr
brew install carthage
brew install svn

# Install MacAppStore console
brew install mas

# Install GUI Apps

brew cask install iterm2
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
brew cask install charles
brew cask install sf-symbols
brew cask install firefox
brew cask install exodus
brew cask install db-browser-for-sqlite

# Fonts

brew tap homebrew/cask-fonts
brew cask install font-montserrat
brew cask install font-jetbrains-mono

# Remove outdated versions from the cellar.
brew cleanup

# Fix Catalina compatibility

xattr -cr /Applications/MacMediaKeyForwarder.app
xattr -cr /Applications/SourceTree.app
