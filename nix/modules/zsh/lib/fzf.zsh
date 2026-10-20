# fzf sources and previews for Ctrl+T, Alt+C, and **<Tab>. Source this file
# after the output of `fzf --zsh`. Ported from the Zim fzf module
# (MIT, Copyright (c) 2021-2025 Eric Nielsen and contributors).
# The commands are looked up at startup, so a missing fd, bat, or eza only
# removes a feature.

() {
  builtin emulate -L zsh
  if (( ${+commands[fd]} )); then
    export FZF_DEFAULT_COMMAND='command fd -H --no-ignore-vcs -E .git -td -tf'
    export FZF_ALT_C_COMMAND='command fd -H --no-ignore-vcs -E .git -td'
    functions[_fzf_compgen_path]='command fd -H --no-ignore-vcs -E .git -td -tf . "${1}"'
    functions[_fzf_compgen_dir]='command fd -H --no-ignore-vcs -E .git -td . "${1}"'
  elif (( ${+commands[rg]} )); then
    export FZF_DEFAULT_COMMAND="command rg -uu -g '!.git' --files --no-messages"
    functions[_fzf_compgen_path]='command rg -uu -g "!.git" --files "${1}"'
  fi
  (( ${+FZF_DEFAULT_COMMAND} )) && export FZF_CTRL_T_COMMAND=${FZF_DEFAULT_COMMAND}

  local ls_cmd='ls --color=always'
  (( ${+commands[eza]} )) && ls_cmd='eza --group-directories-first --color=always'
  if (( ${+commands[bat]} )); then
    export FZF_CTRL_T_OPTS="--bind ctrl-/:toggle-preview --preview 'if [[ -d {} ]]; then ${ls_cmd} -1F -- {}; else bat --color=always --line-range :500 -- {}; fi' ${FZF_CTRL_T_OPTS-}"
  fi
  export FZF_ALT_C_OPTS="--bind ctrl-/:toggle-preview --preview '${ls_cmd} -1F -- {}' ${FZF_ALT_C_OPTS-}"
}
