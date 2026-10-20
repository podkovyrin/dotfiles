# Replaces the zsh-job-queue submodule of zsh-abbr.
# zsh-abbr uses the job queue to order writes to its user file from several
# shells. The abbreviations here come from a read-only file, so nothing is
# written, and the queue would only add about 10 ms to each shell startup.
# zsh-abbr sources this file with the function name suffix as $1.
function job-queue"${1:-}"() {
  typeset -g REPLY=
}
