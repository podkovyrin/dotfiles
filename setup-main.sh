#!/bin/sh

###############################################################################
# Brew

echo
echo "➡️ Setting up brew..."

if test ! $(which brew); then
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
else
    echo "Brew is already installed."
fi

# Make sure we’re using the latest Homebrew.
brew update

# Upgrade any already-installed formulae.
brew upgrade

# Command Line Tools

brew install ruby
brew install python3
brew install virtualenv
brew install gnupg
brew install git
brew install git-lfs
brew install git-secret
brew install tig
brew install cmake
brew install colordiff
brew install tldr
brew install bat # shell
brew install eza # shell, ls
brew install uv
brew install zoxide # shell, z
brew install git-delta
brew install ripgrep # shell
brew install curlie
brew install xcbeautify
brew install btop
brew install fzf # shell
brew install starship # shell, prompt
brew install gh
brew install crowdin
brew install mint

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
# brew install nrlquaker-winbox

# Fonts

brew tap homebrew/cask-fonts
brew install font-montserrat
brew install font-jetbrains-mono
brew install font-jetbrains-mono-nerd-font

# LLMs

brew install ollama
brew install llm
llm install llm-ollama

# Remove outdated versions from the cellar.
brew cleanup

# Fix Catalina compatibility
xattr -cr /Applications/MacMediaKeyForwarder.app

#############################################################################
# Dotfiles

_link_file() {
    local src=$1
    local target=$2

    echo "Set: '${src}' -> '${target}'"
    
    if [ -e "$target" ]; then
        rm -rf "$target"
    fi

    ln -nfs "$src" "$target"
}

echo
echo "➡️ Setting up shell..."

# Configs
_link_file "$(pwd)/config/starship.toml" "$HOME/.config/starship.toml"
_link_file "$(pwd)/config/zsh-abbr" "$HOME/.config/zsh-abbr"

for src in $(pwd)/dot/*; do
    local target="$HOME/.$(basename "$src")"
    _link_file "$src" "$target"
done

# Disable Last Login Message
touch $HOME/.hushlogin

exec zsh -l
