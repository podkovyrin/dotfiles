# zsh-abbr with the abbreviations from Nix. init.zsh sets
# ABBR_USER_ABBREVIATIONS_FILE to a read-only file in the Nix store before it
# sources zsh-abbr, and sources this file after it.

# zsh-abbr saves a change by moving a new file over its user file. Refuse
# the changes that it would save. Session abbreviations (-S) are not saved.
functions[_dotfiles_abbr]=${functions[abbr]}
abbr() {
  local action=${${@:#-*}[1]-}
  # `abbr load` runs abbr for each line of the file.
  if (( ! ABBR_LOADING_USER_ABBREVIATIONS && ! ${@[(I)(-S|--session)]} )) &&
      [[ ${action} == (a|add|e|erase|g|git|R|rename|import-*|*=*) ]]; then
    print -ru2 -- "abbr: the abbreviations come from Nix (dotfiles.zsh.abbreviations). Change them there, or use 'abbr --session' for this shell only."
    return 1
  fi
  _dotfiles_abbr "$@"
}
