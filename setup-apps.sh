#!/bin/sh

###############################################################################
# Package manager

echo
echo "➡️ Setting up brew..."

install_brew() {
    if test ! $(which brew); then
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

        brew update
        brew upgrade
    else
        echo "Brew is already installed."
    fi
}

install_brew


# Make sure we’re using the latest Homebrew.
brew update

# Upgrade any already-installed formulae.
brew upgrade

brew install ruby
brew install python3
brew install virtualenv

# Install GnuPG to enable PGP-signing commits.
brew install gnupg

brew install git
brew install git-lfs
brew install git-secret
brew install tig
brew install mercurial
brew install cmake
brew install colordiff
brew install tldr
brew install carthage
brew install svn
brew install bat
brew install eza
brew install uv
brew install zoxide
brew install git-delta
brew install ripgrep
brew install gitui
brew install curlie
brew install xcbeautify
brew install btop

# GitHub Tools
brew install gh
# GitHub Copilot CLI installation:
# gh auth login
# gh extension install github/gh-copilot

brew install crowdin
brew install mint

# xcodes for the fastest Xcode installs
brew install aria2
brew install xcodesorg/made/xcodes

# Install GUI Apps

brew install iterm2
brew install sublime-text
brew install fork
brew install spotify
brew install the-unarchiver
brew install vlc
brew install macmediakeyforwarder
brew install telegram
brew install opensim
# brew install nrlquaker-winbox
brew install sf-symbols
brew install google-chrome
brew install db-browser-for-sqlite
brew install visual-studio-code
brew install steermouse
brew install anaconda
brew install zoom
brew install jabra-direct
brew install raycast
brew install google-drive
brew install firefox
brew install notunes
brew install MonitorControl
brew install cursor
brew install 1password
brew install android-studio
brew install chatgpt
brew install github-copilot-for-xcode
brew install postman
brew install slack

# Fixes crackling sound issues
# https://developer.apple.com/forums/thread/668170?answerId=675677022#675677022
# brew install blackhole-2ch

# Fonts

brew tap homebrew/cask-fonts
brew install font-montserrat
brew install font-jetbrains-mono
brew install font-jetbrains-mono-nerd-font

# Remove outdated versions from the cellar.
brew cleanup

# LLMs
brew install ollama
brew install llm
llm install llm-ollama

# Fix Catalina compatibility

xattr -cr /Applications/MacMediaKeyForwarder.app
