# Remove older command from the history if a duplicate is to be added.
setopt HIST_IGNORE_ALL_DUPS

# Set editor default keymap to emacs (`-e`) or vi (`-v`)
bindkey -v

# Prompt for spelling correction of commands.
setopt CORRECT

export EDITOR="nvim"
export VISUAL="nvim"

# Remove path separator from WORDCHARS.
WORDCHARS=${WORDCHARS//[\/]}

#############################################################################
# zimfw configuration

# termtitle
#
# Set a custom terminal title format using prompt expansion escape sequences.
# See http://zsh.sourceforge.net/Doc/Release/Prompt-Expansion.html#Simple-Prompt-Escapes
zstyle ':zim:termtitle' format '%~'

# zsh-autosuggestions
#
# Disable automatic widget re-binding on each precmd. This can be set when
# zsh-users/zsh-autosuggestions is the last module in your ~/.zimrc.
ZSH_AUTOSUGGEST_MANUAL_REBIND=1

# zsh-syntax-highlighting
#
# Set what highlighters will be used.
# See https://github.com/zsh-users/zsh-syntax-highlighting/blob/master/docs/highlighters.md
ZSH_HIGHLIGHT_HIGHLIGHTERS=(main brackets)

# Initialize zimfw
#
ZIM_HOME=${ZDOTDIR:-${HOME}}/.zim
# Download zimfw plugin manager if missing.
if [[ ! -e ${ZIM_HOME}/zimfw.zsh ]]; then
  if (( ${+commands[curl]} )); then
    curl -fsSL --create-dirs -o ${ZIM_HOME}/zimfw.zsh \
        https://github.com/zimfw/zimfw/releases/latest/download/zimfw.zsh
  else
    mkdir -p ${ZIM_HOME} && wget -nv -O ${ZIM_HOME}/zimfw.zsh \
        https://github.com/zimfw/zimfw/releases/latest/download/zimfw.zsh
  fi
fi
# Install missing modules, and update ${ZIM_HOME}/init.zsh if missing or outdated.
if [[ ! ${ZIM_HOME}/init.zsh -nt ${ZDOTDIR:-${HOME}}/.zimrc ]]; then
  source ${ZIM_HOME}/zimfw.zsh init -q
fi
# Initialize modules.
source ${ZIM_HOME}/init.zsh

# Post-init module configuration
#
# See https://github.com/zsh-users/zsh-autosuggestions/blob/master/README.md#suggestion-highlight-style
ZSH_AUTOSUGGEST_STRATEGY=( abbreviations history completion )
ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE="fg=243,underline"

# zsh-history-substring-search
#
zmodload -F zsh/terminfo +p:terminfo
# Bind ^[[A/^[[B manually so up/down works both before and after zle-line-init
for key ('^[[A' '^P' ${terminfo[kcuu1]}) bindkey ${key} history-substring-search-up
for key ('^[[B' '^N' ${terminfo[kcud1]}) bindkey ${key} history-substring-search-down
for key ('k') bindkey -M vicmd ${key} history-substring-search-up
for key ('j') bindkey -M vicmd ${key} history-substring-search-down
unset key

# Shortcuts
ls() { command -v eza &> /dev/null && eza "$@" || command ls --color=auto "$@"; }
o() { [[ $# -gt 0 ]] && open "$@" || open .; }
s() { [[ $# -gt 0 ]] && subl "$@" || subl .; }
batrg() { bat "$1" | rg --color=always -C5 "$2" }

alias diff='diff --color=auto'
alias grep='grep --color=auto'
alias cd='z'
alias vim="nvim"

# z
eval "$(zoxide init zsh)"

# prompt

zmodload zsh/datetime 2>/dev/null

setopt prompt_subst

typeset -g LAST_CMD_START_TIME="0"
typeset -g LAST_EXECUTED_CMD=""
typeset -g LAST_DISPLAYED_EXIT_CODE=0

preexec() {
    LAST_CMD_START_TIME=$EPOCHREALTIME
    LAST_EXECUTED_CMD="$1"
}

precmd() {
    local exitcode=$?

    local spent_time_info=""
    local start_time=$LAST_CMD_START_TIME
    if [[ -n $LAST_EXECUTED_CMD && $start_time != 0 ]]; then
        local -i spent_ms=$(( (EPOCHREALTIME - start_time) * 1000 ))
        if (( spent_ms > 500 )); then
            local -i days=$(( spent_ms / 86400000 ))
            local -i hours=$(( (spent_ms / 3600000) % 24 ))
            local -i minutes=$(( (spent_ms / 60000) % 60 ))
            local -i seconds=$(( (spent_ms / 1000) % 60 ))
            local -i millis=$(( spent_ms % 1000 ))
            local -a chunks=()
            (( days )) && chunks+=("${days}d")
            (( hours )) && chunks+=("${hours}h")
            (( minutes )) && chunks+=("${minutes}m")
            (( seconds )) && chunks+=("${seconds}s")
            (( millis )) && chunks+=("${millis}ms")
            if (( ${#chunks[@]} )); then
                local command_text="%F{magenta}${LAST_EXECUTED_CMD}%f"
                local spent_text=" took ${(j: :)chunks}"
                if (( exitcode == 0 )); then
                    spent_time_info="${command_text}%F{blue}${spent_text}%f"
                else
                    spent_time_info="${command_text}%F{red}${spent_text}%f"
                fi
            fi
        fi
    fi
    LAST_EXECUTED_CMD=""

    local prev_exit_command=""
    if (( exitcode != 0 )); then
        if (( exitcode != LAST_DISPLAYED_EXIT_CODE )); then
            prev_exit_command="%F{red}Exit Code: ${exitcode} %f"$'\n'
        fi
        LAST_DISPLAYED_EXIT_CODE=$exitcode
    else
        LAST_DISPLAYED_EXIT_CODE=0
    fi

    local current_path="%F{cyan}%B%~%b%f"
    local python_env=""
    if [[ -n $VIRTUAL_ENV ]]; then
        local relative_env="${VIRTUAL_ENV/#$PWD\//}"
        [[ $relative_env == $VIRTUAL_ENV ]] && relative_env="${VIRTUAL_ENV:A}"
        python_env="(${relative_env}) "
    fi
    RPROMPT="$spent_time_info"
    PS1="${prev_exit_command}${python_env}${current_path} %F{green}%B❯%b%f "
}

# VSCode workaround
if [[ "$TERM_PROGRAM" == "vscode" ]]; then
  . "$(code --locate-shell-integration-path zsh)"
fi
