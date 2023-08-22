#!/bin/sh

# Install command-line tools using Homebrew.

brew || /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

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
brew install git-secret
brew install tig
brew install gh
brew install mercurial
brew install cmake
brew install colordiff
brew install tldr
brew install carthage
brew install svn
brew install bazelisk

brew install cocoapods
brew install crowdin
brew install mint

brew install exa
brew install bat
brew install httpie


# Install GUI Apps

brew install iterm2
brew install sublime-text
brew install fork
brew install spotify
brew install the-unarchiver
brew install vlc
brew install macmediakeyforwarder
brew install skype
brew install telegram
brew install opensim
brew install wwdc
brew install nrlquaker-winbox
brew install sf-symbols
brew install chrome
brew install db-browser-for-sqlite
brew install visual-studio-code
brew install nvm

# Fixes crackling sound issues
# https://developer.apple.com/forums/thread/668170?answerId=675677022#675677022
brew install blackhole-2ch

# Fonts

brew tap homebrew/cask-fonts
brew install font-montserrat
brew install font-jetbrains-mono

# Remove outdated versions from the cellar.
brew cleanup

# Fix Catalina compatibility

xattr -cr /Applications/MacMediaKeyForwarder.app
