#!/bin/zsh

set -e

script_dir=${0:A:h}
cd "$script_dir"

setup_brew() {
    echo
    echo "➡️ Setting up brew..."

    if ! command -v brew > /dev/null 2>&1; then
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

        if [[ -x /opt/homebrew/bin/brew ]]; then
            eval "$(/opt/homebrew/bin/brew shellenv)"
        elif [[ -x /usr/local/bin/brew ]]; then
            eval "$(/usr/local/bin/brew shellenv)"
        else
            echo "Homebrew installed but its executable was not found." >&2
            return 1
        fi
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
    brew install mas
    brew install duti
    brew install fastfetch
    brew install yazi
    brew install tmux
    brew install gitmux
    brew install git-delta
    brew install mole

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
    brew install zed
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

    # Fonts

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

    # Tool versions are declared in mise/.config/mise/conf.d/10-dotfiles.toml.
    # Keeping the declarations in one place prevents setup from rewriting the
    # tracked config through `mise use --global`.
    mise install
}

setup_dotfiles() {
    echo
    echo "➡️ Setting up dotfiles..."

    # These two files used to live in packages that are now platform-neutral.
    # Remove only our known, obsolete symlinks before restowing the new layout.
    if [[ -L "$HOME/.config/mise/config.toml" &&
          "$(readlink "$HOME/.config/mise/config.toml")" == *".dotfiles/mise/.config/mise/config.toml" ]]; then
        unlink "$HOME/.config/mise/config.toml"
    fi
    if [[ -L "$HOME/Library/Preferences/pnpm/rc" &&
          "$(readlink "$HOME/Library/Preferences/pnpm/rc")" == *".dotfiles/pnpm/Library/Preferences/pnpm/rc" ]]; then
        unlink "$HOME/Library/Preferences/pnpm/rc"
    fi

    local packages=(
        zsh git nvim editorconfig editrc gem aerospace btop ghostty tmux zed
        mise uv npmrc pnpm pnpm-macos yarn bun
    )
    local package
    for package in "${packages[@]}"; do
        stow --restow --no-folding "$package"
    done

    # Disable Last Login Message
    touch "$HOME/.hushlogin"
}

###############################################################################

setup_brew

setup_dotfiles

setup_devtools

exec zsh -l
