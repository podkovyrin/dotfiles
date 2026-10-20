# Completion: compinit with a cached dump file, and the completion styles.
# Set fpath before this file. The styles are ported from the Zim completion
# module (MIT, Copyright (c) 2009-2011 Robby Russell and contributors).

[[ ${TERM} != dumb ]] || return 0

if (( ${+_comps} )); then
  print -ru2 -- 'zsh: compinit already ran before completion.zsh. Remove the other compinit call.'
fi

() {
  builtin emulate -LR zsh -o EXTENDED_GLOB
  local cache=${XDG_CACHE_HOME:-${HOME}/.cache}/zsh
  local dump=${cache}/zcompdump-${ZSH_VERSION} dir  # One per version: /bin/zsh can also run.
  local -a key files mtimes

  # The dump is valid while the completion functions in fpath stay the same.
  # A /nix/store directory never changes, so its resolved path is enough.
  # For other directories, use the name and mtime of each function file.
  for dir in ${^fpath}(N-/); do
    dir=${dir:A}
    key+=( ${dir} )
    [[ ${dir} == /nix/store/* ]] && continue
    # -. skips broken links, for example to an app that was removed.
    files=( ${dir}/^([^_]*|*~|*.zwc)(N-.) )
    (( ${#files} )) || continue
    zmodload -F zsh/stat b:zstat && zstat -A mtimes +mtime ${files} || return 1
    key+=( ${files} ${mtimes} )
  done

  [[ -d ${cache} ]] || command mkdir -p ${cache} || return 1
  if [[ ! -r ${dump}.key || $(<${dump}.key) != ${(pj:\n:)key} ]]; then
    command rm -f ${dump}(|.key|.zwc)(N) || return 1
  fi

  # -C skips compaudit. compinit writes a missing dump file.
  autoload -Uz compinit && compinit -C -d ${dump} && [[ -e ${dump} ]] || return 1
  [[ -e ${dump}.key ]] || print -r -- ${(pj:\n:)key} >| ${dump}.key
  [[ ${dump}.zwc -nt ${dump} ]] || zcompile -R ${dump}
}

# Warn when something calls compinit again: the second call is slow and
# replaces the completions that were added with compdef in between.
functions[compinit]=$'print -ru2 -- "zsh: compinit called again at ${funcfiletrace[1]}"\n'${functions[compinit]}

# Caching and menu
zstyle ':completion::complete:*' use-cache on
zstyle ':completion::complete:*' cache-path ${XDG_CACHE_HOME:-${HOME}/.cache}/zsh/zcompcache
zstyle ':completion:*' menu select

# Group the matches and describe them.
zstyle ':completion:*:matches' group yes
zstyle ':completion:*:options' description yes
zstyle ':completion:*:options' auto-description '%d'
zstyle ':completion:*:corrections' format '%F{green}-- %d (errors: %e) --%f'
zstyle ':completion:*:descriptions' format '%F{yellow}-- %d --%f'
zstyle ':completion:*:messages' format '%F{purple}-- %d --%f'
zstyle ':completion:*:warnings' format '%F{red}-- no matches found --%f'
zstyle ':completion:*' group-name ''
zstyle ':completion:*' verbose yes

# Smart case: lowercase also matches uppercase. Then partial words and substrings.
# The fully case-insensitive matcher is broken in zsh 5.9:
# https://www.zsh.org/mla/workers/2022/msg01229.html
zstyle ':completion:*' matcher-list 'm:{[:lower:]}={[:upper:]}' '+r:|[._-]=* r:|=*' '+l:|=*'

# Complete on an empty line too.
zstyle ':completion:*' insert-tab false

# Skip internal functions, and sort array subscripts.
zstyle ':completion:*:functions' ignored-patterns '(_*|pre(cmd|exec)|prompt_*)'
zstyle ':completion:*:*:-subscript-:*' tag-order 'indexes' 'parameters'

# Directories
if (( ${+LS_COLORS} )); then
  zstyle ':completion:*:default' list-colors ${(s.:.)LS_COLORS}
else
  zstyle ':completion:*:default' list-colors ${(s.:.):-di=1;34:ln=35:so=32:pi=33:ex=31:bd=1;36:cd=1;33:su=30;41:sg=30;46:tw=30;42:ow=30;43}
fi
zstyle ':completion:*:*:cd:*:directory-stack' menu yes select
zstyle ':completion:*' squeeze-slashes true

# History words
zstyle ':completion:*:history-words' stop yes
zstyle ':completion:*:history-words' remove-all-dups yes
zstyle ':completion:*:history-words' list false
zstyle ':completion:*:history-words' menu yes

# Host names from known_hosts, /etc/hosts, and ~/.ssh/config.
zstyle -e ':completion:*:hosts' hosts 'reply=(
  ${=${=${=${${(f)"$(cat {/etc/ssh/ssh_,~/.ssh/}known_hosts{,2} 2>/dev/null)"}%%[#| ]*}//\]:[0-9]*/ }//,/ }//\[/ }
  ${=${(f)"$(cat /etc/hosts 2>/dev/null)"}%%(\#)*}
  ${=${${${${(@M)${(f)"$(cat ~/.ssh/config{,.d/*(N)} 2>/dev/null)"}:#Host *}#Host }:#*\**}:#*\?*}}
)'

# Skip system users, unless they are the only match.
zstyle ':completion:*:*:*:users' ignored-patterns \
  '_*' adm amanda apache avahi beaglidx bin cacti canna clamav daemon dbus \
  distcache dovecot fax ftp games gdm gkrellmd gopher hacluster haldaemon \
  halt hsqldb ident junkbust ldap lp mail mailman mailnull mldonkey mysql \
  nagios named netdump news nfsnobody nobody nscd ntp nut nx openvpn \
  operator pcap postfix postgres privoxy pulse pvm quagga radvd rpc rpcuser \
  rpm shutdown squid sshd sync uucp vcsa xfs
zstyle ':completion:*' single-ignored show

# Do not offer a file that is already on the line.
zstyle ':completion:*:(rm|kill|diff):*' ignore-line other
zstyle ':completion:*:rm:*' file-patterns '*:all-files'

# Man pages
zstyle ':completion:*:manuals' separate-sections true
zstyle ':completion:*:manuals.(^1*)' insert-sections true
