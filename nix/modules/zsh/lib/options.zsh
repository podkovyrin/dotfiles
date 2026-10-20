# Shell options and history. Ported from the Zim environment and completion
# modules (MIT, Copyright (c) 2015-2016 Matt Hamilton and contributors).

# Changing directories
setopt AUTO_CD             # Type a directory name to cd into it.
setopt AUTO_PUSHD          # cd pushes the old directory onto the stack.
setopt CD_SILENT           # Do not print the directory after cd.
setopt PUSHD_IGNORE_DUPS
setopt PUSHD_SILENT
setopt PUSHD_TO_HOME       # pushd without arguments goes to $HOME.

# Expansion, globbing, and completion
setopt EXTENDED_GLOB       # Treat #, ~, and ^ as glob patterns.
# init.zsh sets NO_CASE_GLOB at the end. A case-insensitive glob reads every
# directory in the path, and /nix/store is large: the plugins glob in the
# store when they load.
setopt ALWAYS_TO_END       # Move the cursor to the end of a completed word.
setopt COMPLETE_IN_WORD    # Complete from both ends of the cursor.
setopt NO_LIST_BEEP

# History
HISTFILE=${ZDOTDIR:-$HOME}/.zsh_history
HISTSIZE=20000             # Larger than SAVEHIST for HIST_EXPIRE_DUPS_FIRST.
SAVEHIST=10000
setopt HIST_FCNTL_LOCK
setopt HIST_FIND_NO_DUPS
setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_SPACE   # A command that starts with a space is not saved.
setopt HIST_VERIFY         # Show a history expansion before it runs.
setopt SHARE_HISTORY

# Input and output
setopt INTERACTIVE_COMMENTS
setopt NO_CLOBBER          # > does not overwrite a file. Use >| to overwrite.

# Jobs
setopt LONG_LIST_JOBS
setopt NO_BG_NICE
setopt NO_CHECK_JOBS
setopt NO_HUP
