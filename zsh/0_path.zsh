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
