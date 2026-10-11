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

    # Install what the Brewfile declares. Upgrades go through upgate.
    # Edit it when you install or remove packages; `brewextra` lists strays.
    brew bundle install --no-upgrade --file="$script_dir/Brewfile"

    # Remove outdated versions from the cellar.
    brew cleanup

    # Fix Catalina compatibility
    xattr -cr /Applications/MacMediaKeyForwarder.app
}

setup_devtools() {
    echo
    echo "➡️ Setting up devtools..."

    # mise and the Ruby build dependencies come from the Brewfile.
    eval "$(mise activate zsh)"

    # Tool versions are declared in mise/.config/mise/conf.d/10-dotfiles.toml.
    # Keeping the declarations in one place prevents setup from rewriting the
    # tracked config through `mise use --global`.
    mise install

    echo
    echo "Installing Pi with the official installer..."
    (
        set -o pipefail
        curl -fsSL https://pi.dev/install.sh | mise exec -- sh
    )
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
        zsh git nvim editorconfig editrc gem aerospace omniwm karabiner btop ghostty tmux zed
        mise uv npmrc pnpm pnpm-macos yarn bun herdr macos starship
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
