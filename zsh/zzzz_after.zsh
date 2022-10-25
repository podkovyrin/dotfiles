# Load any custom after code
if [ -d $HOME/.zsh.after/ ]; then
  if [ "$(ls -a $HOME/.zsh.after/)" ]; then
    for config_file ($HOME/.zsh.after/*.zsh) source $config_file
  fi
fi
