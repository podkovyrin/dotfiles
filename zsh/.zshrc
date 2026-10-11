# Remove older command from the history if a duplicate is to be added.
setopt HIST_IGNORE_ALL_DUPS

# Set editor default keymap to emacs (`-e`) or vi (`-v`)
bindkey -v

# Guard against broken TTY input flags (Enter shows as ^M when icrnl is off).
# Some programs can leave the terminal in this state for the current session.
fix_tty_enter_key() {
  [[ -t 0 ]] || return
  stty icrnl -inlcr -igncr 2>/dev/null
}
(( ${precmd_functions[(Ie)fix_tty_enter_key]} )) || precmd_functions+=(fix_tty_enter_key)
fix_tty_enter_key

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

[[ -r ~/.config/herdr/process-name.zsh ]] && source ~/.config/herdr/process-name.zsh

# pnpm completion: cache the script and refresh it when the pnpm binary changes.
# Generate it outside $HOME: there, pnpm reads ~/.npmrc as a project .npmrc
# and warns about the env-var auth tokens.
if (( ${+commands[pnpm]} )); then
  _pnpm_comp=${XDG_CACHE_HOME:-$HOME/.cache}/zsh/pnpm-completion.zsh
  if [[ ! -s $_pnpm_comp || ${commands[pnpm]:A} -nt $_pnpm_comp ]]; then
    mkdir -p ${_pnpm_comp:h}
    (cd /tmp && pnpm completion zsh 2>/dev/null) >| $_pnpm_comp
  fi
  source $_pnpm_comp
  unset _pnpm_comp
fi

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
o() {
  local opener
  if (( ${+commands[open]} )); then
    opener=open
  elif (( ${+commands[xdg-open]} )); then
    opener=xdg-open
  else
    print -u2 "No file opener found"
    return 127
  fi
  [[ $# -gt 0 ]] && command "$opener" "$@" || command "$opener" .
}
s() { [[ $# -gt 0 ]] && subl "$@" || subl .; }
batrg() { bat "$1" | rg --color=always -C5 "$2" }

alias diff='diff --color=auto'
alias grep='grep --color=auto'
alias cd='z'
alias v="nvim"

# z
(( ${+commands[zoxide]} )) && eval "$(zoxide init zsh)"

# prompt

(( ${+commands[starship]} )) && eval "$(starship init zsh)"

# VSCode workaround
if [[ "$TERM_PROGRAM" == "vscode" ]]; then
  . "$(code --locate-shell-integration-path zsh)"
fi
