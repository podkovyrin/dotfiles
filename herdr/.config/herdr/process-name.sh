# Shared helpers for the Zsh and Bash command hooks.
[[ -n ${HERDR_PANE_ID:-} ]] || return 0
command -v jq >/dev/null 2>&1 || return 0
_herdr_process_bin=${HERDR_BIN_PATH:-herdr}
command -v "$_herdr_process_bin" >/dev/null 2>&1 || return 0

_herdr_process_begin() {
    local label previous
    [[ -z ${_herdr_process_label:-} ]] || return 0
    while [[ $# -gt 0 ]]; do
        case $1 in
            *=*|command|builtin|exec|env) shift ;;
            *) break ;;
        esac
    done
    [[ $# -gt 0 ]] || return 0
    label=${1##*/}
    case $label in
        ''|-*|cd|exit|logout|herdr|pi|claude|codex|opencode) return 0 ;;
    esac
    previous=$("$_herdr_process_bin" pane get "$HERDR_PANE_ID" 2>/dev/null |
        jq -er '.result.pane | select(.pane_id != null and .agent == null) | .label // ""' 2>/dev/null) || return 0
    if "$_herdr_process_bin" pane rename "$HERDR_PANE_ID" "$label" >/dev/null 2>&1; then
        _herdr_process_previous=$previous
        _herdr_process_label=$label
    fi
    return 0
}

_herdr_process_end() {
    local previous
    [[ -n ${_herdr_process_label:-} ]] || return 0
    # Preserve a name that the user changes while the command runs.
    if previous=$("$_herdr_process_bin" pane get "$HERDR_PANE_ID" 2>/dev/null |
        jq -er --arg label "$_herdr_process_label" --arg previous "$_herdr_process_previous" \
            '.result.pane | select(.label == $label) | $previous' 2>/dev/null); then
        if [[ -n $previous ]]; then
            "$_herdr_process_bin" pane rename "$HERDR_PANE_ID" "$previous" >/dev/null 2>&1
        else
            "$_herdr_process_bin" pane rename "$HERDR_PANE_ID" --clear >/dev/null 2>&1
        fi
    fi
    unset _herdr_process_label _herdr_process_previous
    return 0
}
