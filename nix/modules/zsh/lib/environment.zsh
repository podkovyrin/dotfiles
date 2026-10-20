# Pager and colours. Ported from the Zim utility module
# (MIT, Copyright (c) 2015-2016 Matt Hamilton and contributors).
# A value that is already set, for example by Home Manager, is kept.

(( ${+PAGER} )) || export PAGER=less
(( ${+LESS} )) || export LESS='--ignore-case --jump-target=4 --LONG-PROMPT --no-init --quit-if-one-screen --RAW-CONTROL-CHARS'

# See https://no-color.org.
if [[ -z ${NO_COLOR-} ]]; then
  (( ${+GREP_COLOR} )) || export GREP_COLOR='37;45'                # BSD grep
  (( ${+GREP_COLORS} )) || export GREP_COLORS="mt=${GREP_COLOR}"   # GNU grep

  # Man pages in less.
  (( ${+LESS_TERMCAP_mb} )) || export LESS_TERMCAP_mb=$'\E[1;31m'  # Begin blink.
  (( ${+LESS_TERMCAP_md} )) || export LESS_TERMCAP_md=$'\E[1;31m'  # Begin bold.
  (( ${+LESS_TERMCAP_me} )) || export LESS_TERMCAP_me=$'\E[0m'     # End mode.
  (( ${+LESS_TERMCAP_ue} )) || export LESS_TERMCAP_ue=$'\E[0m'     # End underline.
  (( ${+LESS_TERMCAP_us} )) || export LESS_TERMCAP_us=$'\E[1;32m'  # Begin underline.

  # BSD ls.
  export CLICOLOR=1
  (( ${+LSCOLORS} )) || export LSCOLORS=ExfxcxdxbxGxDxabagacad
fi
