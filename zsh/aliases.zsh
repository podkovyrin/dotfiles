# Aliases in this file are bash and zsh compatible

# Don't change. The following determines where YADR is installed.
yadr=$HOME/.yadr

# disable alias "o" defined in prezto to fix "o" function
unalias -m "o"

# Get operating system
platform='unknown'
unamestr=$(uname)
if [[ $unamestr == 'Linux' ]]; then
  platform='linux'
elif [[ $unamestr == 'Darwin' ]]; then
  platform='darwin'
fi

# YADR support
alias yup='pushd $yadr && git pull --rebase && git submodule update --init && rake update && rake submodules && popd'

# PS
alias psa="ps aux"
alias psg="ps aux | grep "
alias psr='ps aux | grep ruby'

# Moving around
alias cdb='cd -'
alias icloud='cd ~/Library/Mobile\ Documents/com~apple~CloudDocs/'

# Show human friendly numbers and colors
alias df='df -h'
alias du='du -h -d 2'

# Always enable colored `grep` output
# Note: `GREP_OPTIONS="--color=auto"` is deprecated, hence the alias usage.
alias grep='grep --color=auto'
alias fgrep='fgrep --color=auto'
alias egrep='egrep --color=auto'

if [[ $platform == 'linux' ]]; then
  alias ll='ls -alh --color=auto'
  alias ls='ls --color=auto'
elif [[ $platform == 'darwin' ]]; then
  alias ll='ls -alGh'
  alias ls='ls -Gh'
fi

# show me files matching "ls grep"
alias lsg='ll | grep'

# Alias Editing
TRAPHUP() {
  source $yadr/zsh/aliases.zsh
}

alias ae='vim $yadr/zsh/aliases.zsh' #alias edit
alias ar='source $yadr/zsh/aliases.zsh'  #alias reload
alias gar="killall -HUP -u \"$USER\" zsh"  #global alias reload

# mimic vim functions
alias :q='exit'

# IP addresses
alias ip="dig +short myip.opendns.com @resolver1.opendns.com"
alias localip="ipconfig getifaddr en0"

# Recursively delete `.DS_Store` files
alias cleanup="find . -type f -name '*.DS_Store' -ls -delete"

# PlistBuddy alias, because sometimes `defaults` just doesn’t cut it
alias plistbuddy="/usr/libexec/PlistBuddy"

# Common shell functions
alias less='less -r'
alias tf='tail -f'
alias l='less'
alias lh='ls -alt | head' # see the last modified files
alias cl='clear'

# Zippin
alias gz='tar -zcvf'

#
alias ka9='killall -9'
alias k9='kill -9'

# Cocoapods
alias piu="pod install --repo-update && osascript -e 'display notification \"Cocoapods installed and repo updated\" with title \"iTerm2\"'"
alias pi="pod install && osascript -e 'display notification \"Cocoapods installed\" with title \"iTerm2\"'"
alias pipod="pod install --project-directory=Example && osascript -e 'display notification \"Cocoapods installed\" with title \"iTerm2\"'"

# Misc
# alias jsp='underscore print --color'
alias xtrmntdd='rm -rf ~/Library/Developer/Xcode/DerivedData'
alias t='tig --all'

# Maintance
alias brewu='brew update && brew upgrade && brew cleanup && brew doctor'
alias gemu='gem update && gem cleanup'
alias clean_my_mac='$yadr/clean_my_mac/clean_my_mac.sh'
alias chores='$yadr/chores/chores.sh'
