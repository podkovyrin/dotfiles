[[ $- == *i* && -n ${HERDR_PANE_ID:-} ]] || return 0
[[ -z ${_HERDR_PROCESS_NAMES_LOADED:-} ]] || return 0
# Omarchy's Bash prompt leaves the DEBUG trap available.
[[ -z $(trap -p DEBUG) ]] || return 0
source "$(dirname -- "${BASH_SOURCE[0]}")/process-name.sh"
declare -F _herdr_process_begin >/dev/null || return 0
_HERDR_PROCESS_NAMES_LOADED=1
_herdr_process_ready=0

_herdr_process_bash_debug() {
    local -a words
    [[ ${BASH_SUBSHELL:-0} == 0 ]] || return 0
    case $1 in
        starship_precmd|_herdr_process_bash_prompt) return 0 ;;
    esac
    [[ $_herdr_process_ready == 1 ]] || return 0
    _herdr_process_ready=0
    read -r -a words <<< "$1"
    _herdr_process_begin "${words[@]}"
}

_herdr_process_bash_prompt() {
    local exit_code=$?
    _herdr_process_end
    _herdr_process_ready=1
    return "$exit_code"
}

if [[ $(declare -p PROMPT_COMMAND 2>/dev/null) == 'declare -a '* ]]; then
    PROMPT_COMMAND+=(_herdr_process_bash_prompt)
else
    PROMPT_COMMAND=${PROMPT_COMMAND:+"$PROMPT_COMMAND; "}_herdr_process_bash_prompt
fi
trap '_herdr_process_bash_debug "$BASH_COMMAND"' DEBUG
