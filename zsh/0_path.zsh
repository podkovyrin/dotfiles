# path, the 0 in the filename causes this to load first

pathInsert() {
  # Only adds to the path if it's not already there
  if ! echo $PATH | egrep -q "(^|:)$1($|:)" ; then
    PATH=$1:$PATH
  fi
}

# Remove duplicate entries from PATH:
PATH=$(echo "$PATH" | awk -v RS=':' -v ORS=":" '!a[$1]++{if (NR > 1) printf ORS; printf $a[$1]}')

pathInsert "$HOME/.fastlane/bin"
pathInsert "/usr/local/sbin"
pathInsert "/usr/local/opt/ruby/bin"

pathInsert "/opt/homebrew/bin"
pathInsert "/opt/homebrew/sbin"
pathInsert "/Applications/Sublime Text.app/Contents/SharedSupport/bin"

pathInsert "/opt/homebrew/opt/ruby/bin"

export HOMEBREW_PREFIX="/opt/homebrew";
export HOMEBREW_CELLAR="/opt/homebrew/Cellar";
export HOMEBREW_REPOSITORY="/opt/homebrew";
export HOMEBREW_SHELLENV_PREFIX="/opt/homebrew";
export MANPATH="/opt/homebrew/share/man${MANPATH+:$MANPATH}:";
export INFOPATH="/opt/homebrew/share/info:${INFOPATH:-}";
