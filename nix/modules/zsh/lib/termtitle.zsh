# Set the terminal title before each prompt.
# Usage: source termtitle.zsh <prompt-format>
# Ported from the Zim termtitle module (MIT, Copyright (c) 2019-2026 Eric
# Nielsen and contributors).

[[ ${TERM} != dumb ]] || return 0

() {
  builtin emulate -L zsh
  if [[ ${TERM_PROGRAM-} == Apple_Terminal ]]; then
    # Terminal.app shows the directory from OSC 7.
    functions[_termtitle_precmd]='print -n "\E]7;${PWD}\a"'
  elif [[ ${TERM} == screen ]]; then
    functions[_termtitle_precmd]="print -Pn '\Ek'${(qq)1}'\E\\'"
  else
    functions[_termtitle_precmd]="print -Pn '\E]0;'${(qq)1}'\a'"
  fi
  autoload -Uz add-zsh-hook
  add-zsh-hook precmd _termtitle_precmd
} "${1:-%n@%m: %~}"
