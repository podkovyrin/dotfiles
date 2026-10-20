# Key bindings for the main keymap. init.zsh selects the keymap (emacs or vi)
# before it sources this file. Ported from the Zim input module
# (MIT, Copyright (c) 2015-2016 Matt Hamilton and contributors).

[[ ${TERM} != dumb ]] || return 0

() {
  builtin emulate -L zsh
  zmodload -F zsh/terminfo +b:echoti +p:terminfo

  local key
  for key ('\e[1;5D' '\e[5D' '\e\e[D' '\eOd' '\eOD') bindkey ${key} backward-word  # Ctrl+Left
  for key ('\e[1;5C' '\e[5C' '\e\e[C' '\eOc' '\eOC') bindkey ${key} forward-word   # Ctrl+Right

  bindkey '^[[3~' delete-char
  bindkey '^?' backward-delete-char

  # Bind a key only when terminfo knows it.
  local -A keys=(
    khome beginning-of-line
    kend  end-of-line
    kpp   up-line-or-history
    knp   down-line-or-history
    kich1 overwrite-mode
    kcub1 backward-char
    kcuf1 forward-char
    kcbt  reverse-menu-complete  # Shift+Tab: previous menu item.
  )
  for key (${(k)keys}) [[ -n ${terminfo[${key}]} ]] && bindkey ${terminfo[${key}]} ${keys[${key}]}

  bindkey ' ' magic-space        # Expand history references on space.
  bindkey '\e.' insert-last-word # Also in vi insert mode.
  bindkey '\e_' insert-last-word

  # Ctrl+X Ctrl+E edits the command line in $EDITOR.
  autoload -Uz edit-command-line && zle -N edit-command-line && bindkey '^X^E' edit-command-line

  # Quote URLs as they are typed or pasted.
  autoload -Uz bracketed-paste-url-magic && zle -N bracketed-paste bracketed-paste-url-magic
  autoload -Uz url-quote-magic && zle -N self-insert url-quote-magic

  # Application mode while zle is active, so that the terminfo key codes apply.
  if (( ${+terminfo[smkx]} && ${+terminfo[rmkx]} &&
      ! ${+functions[_start_application_mode]} && ! ${+functions[_stop_application_mode]} )); then
    functions[_start_application_mode]=${widgets[zle-line-init]#user:}$'\nechoti smkx'
    functions[_stop_application_mode]=${widgets[zle-line-finish]#user:}$'\nechoti rmkx'
    zle -N zle-line-init _start_application_mode
    zle -N zle-line-finish _stop_application_mode
  fi
}
