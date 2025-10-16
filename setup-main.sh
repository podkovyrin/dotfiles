#!/bin/zsh

setup_brew() {
    echo
    echo "➡️ Setting up brew..."

    if test ! $(which brew); then
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

        eval "$(/opt/homebrew/bin/brew shellenv)"
    else
        echo "Brew is already installed."
    fi

    # Make sure we’re using the latest Homebrew.
    brew update

    # Upgrade any already-installed formulae.
    brew upgrade

    # Command Line Tools

    brew install stow
    brew install lua
    brew install cmake
    brew install mint
    brew install gnupg
    brew install git
    brew install git-lfs
    brew install git-secret
    brew install tig
    brew install tldr
    brew install bat # shell
    brew install eza # shell, ls
    brew install fd # shell, find
    brew install zoxide # shell, z
    brew install ripgrep # shell
    brew install curlie
    brew install btop
    brew install fzf # shell
    brew install starship # shell, prompt
    brew install mas
    brew install duti
    brew install fastfetch
    brew install yazi

    # Install GUI Apps

    brew install ghostty
    brew install sublime-text
    brew install fork
    brew install spotify
    brew install the-unarchiver
    brew install vlc
    brew install macmediakeyforwarder
    brew install telegram
    brew install sf-symbols
    brew install google-chrome
    brew install db-browser-for-sqlite
    brew install visual-studio-code
    brew install steermouse
    brew install zoom
    brew install raycast
    brew install google-drive
    brew install notunes
    brew install MonitorControl
    brew install 1password
    brew install android-studio
    brew install chatgpt
    brew install slack
    brew install --no-quarantine grishka/grishka/neardrop
    brew install --cask nikitabobko/tap/aerospace

    # brew install nrlquaker-winbox
    # brew install postman
    # brew install anaconda
    # brew install jabra-direct # outdated - Rosetta
    # brew install opensim # outdated - Rosetta

    # Sketchybar
    brew install FelixKratz/formulae/sketchybar
    brew install switchaudio-osx
    brew install daipeihust/tap/im-select
    # + lua, installed above
    (git clone https://github.com/FelixKratz/SbarLua.git /tmp/SbarLua && cd /tmp/SbarLua/ && make install && rm -rf /tmp/SbarLua/)

    # Fonts

    brew tap homebrew/cask-fonts
    brew install font-montserrat
    brew install font-jetbrains-mono
    # TODO: consider removing
    brew install font-jetbrains-mono-nerd-font
    brew install --cask font-sf-mono
    brew install --cask font-sf-pro

    # LLMs

    # brew install ollama
    # brew install llm
    # llm install llm-ollama

    # Remove outdated versions from the cellar.
    brew cleanup

    # Fix Catalina compatibility
    xattr -cr /Applications/MacMediaKeyForwarder.app
}

setup_devtools() {
    echo
    echo "➡️ Setting up devtools..."
    
    brew install mise
    eval "$(mise activate zsh)"

    # Dependencies ruby
    # https://github.com/rbenv/ruby-build/wiki#suggested-build-environment
    brew install openssl@3
    brew install readline
    brew install libyaml
    brew install gmp
    brew install autoconf

    mise use -g rust
    mise use -g node@lts
    mise use -g go
    mise use -g python
    mise use -g ruby
    mise use -g uv
    mise use -g xcbeautify
    mise use -g gh

    mise use -g npm:@anthropic-ai/claude-code
    mise use -g npm:@openai/codex

    mise use -g npm:@crowdin/cli
}

setup_dotfiles() {
    echo
    echo "➡️ Setting up dotfiles..."

    stow zsh
    stow starship
    stow git
    stow vim
    stow editorconfig
    stow editrc
    stow gem
    stow aerospace
    stow sketchybar
    stow btop
    stow ghostty

    git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
    stow tmux

    # Disable Last Login Message
    touch $HOME/.hushlogin
}

###############################################################################

setup_brew

setup_dotfiles

setup_devtools

exec zsh -l
