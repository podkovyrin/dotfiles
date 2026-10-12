[[ -o interactive && -n ${HERDR_PANE_ID:-} ]] || return 0
[[ -z ${_HERDR_PROCESS_NAMES_LOADED:-} ]] || return 0
source "${${(%):-%N}:A:h}/process-name.sh"
(( $+functions[_herdr_process_begin] )) || return 0
_HERDR_PROCESS_NAMES_LOADED=1

_herdr_process_preexec() {
    local -a words
    words=( ${(z)${2:-$1}} )
    words=( "${(@Q)words}" )
    _herdr_process_begin "${words[@]}"
}

autoload -Uz add-zsh-hook
add-zsh-hook preexec _herdr_process_preexec
add-zsh-hook precmd _herdr_process_end
add-zsh-hook zshexit _herdr_process_end
