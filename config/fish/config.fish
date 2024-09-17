set fish_greeting

# Global variables:

set -Ux LC_ALL en_US.UTF-8
set -Ux LANG en_US.UTF-8
set -Ux HOMEBREW_PREFIX /opt/homebrew
set -Ux HOMEBREW_CELLAR /opt/homebrew/Cellar
set -Ux HOMEBREW_REPOSITORY /opt/homebrew
set -Ux HOMEBREW_SHELLENV_PREFIX /opt
set -Ux MANPATH /opt/homebrew/share/man
set -Ux INFOPATH /opt/homebrew/share/info
set -Ux FASTLANE_USER podkovyrin@gmail.com


# PATH

fish_add_path "/opt/homebrew/bin"
fish_add_path "/opt/homebrew/sbin"
fish_add_path "/Applications/Sublime Text.app/Contents/SharedSupport/bin"
fish_add_path "/opt/homebrew/opt/ruby/bin"
fish_add_path "$HOME/.mint/bin"

# Abbrevation definition helpers

source $HOME/.config/fish/abbr.fish

# Abbrevations:

abbr -a "p3" "python3"

abbr -a localsrv "python3 -m http.server"

abbr -a plistbuddy /usr/libexec/PlistBuddy
abbr -a xcgen "mint run xcodegen"
abbr -a slint "mint run swiftlint --quiet"
abbr -a xtrmntdd "rm -rf ~/Library/Developer/Xcode/DerivedData"

abbr -a chores "$HOME/.dotfiles/scripts/chores.sh"

abbr -a ml_on "$HOMEBREW_PREFIX/anaconda3/bin/conda config --set auto_activate_base true"
abbr -a ml_off "$HOMEBREW_PREFIX/anaconda3/bin/conda config --set auto_activate_base false"
abbr -a ml_start "$HOMEBREW_PREFIX/anaconda3/bin/jupyter_mac.command"

abbr -a !! --position anywhere --function last_history_item

abbr -a fix_llama "find . -type f -perm +111 -exec xattr -cr {} +"

abbr_subcommand brew i install

source $HOME/.config/fish/git.fish

zoxide init fish | source
starship init fish | source
