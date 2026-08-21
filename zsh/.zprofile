path=("$HOME/.local/bin" "$HOME/.mint/bin" $path)

case "$OSTYPE" in
  darwin*)
    export MANPATH="/opt/homebrew/share/man:${MANPATH:-}"
    export INFOPATH="/opt/homebrew/share/info:${INFOPATH:-}"
    export BOOST_ROOT=/opt/homebrew/opt/boost
    export ANDROID_HOME="$HOME/Library/Android/sdk"

    if [[ -x /usr/libexec/java_home ]]; then
      export JAVA_HOME="$(/usr/libexec/java_home)"
    fi

    path=(
      "/Applications/Sublime Text.app/Contents/SharedSupport/bin"
      "/opt/homebrew/opt/llvm/bin"
      $path
    )
    export LDFLAGS="-L/opt/homebrew/opt/llvm/lib"
    export CPPFLAGS="-I/opt/homebrew/opt/llvm/include"
    export CMAKE_PREFIX_PATH="/opt/homebrew/opt/llvm"
    ;;
  linux*)
    [[ -d "$HOME/Android/Sdk" ]] && export ANDROID_HOME="$HOME/Android/Sdk"
    ;;
esac

if [[ -n ${ANDROID_HOME:-} ]]; then
  path=("$ANDROID_HOME/platform-tools" "$ANDROID_HOME/cmdline-tools/latest/bin" $path)
fi

[[ -r "$HOME/.secrets" ]] && source "$HOME/.secrets"

# brew and mise activation should be executed after setting $PATH

if [[ "$OSTYPE" == darwin* ]]; then
  if (( $+commands[brew] )); then
    brew_command=${commands[brew]}
  elif [[ -x /opt/homebrew/bin/brew ]]; then
    brew_command=/opt/homebrew/bin/brew
  elif [[ -x /usr/local/bin/brew ]]; then
    brew_command=/usr/local/bin/brew
  fi

  if [[ -n ${brew_command:-} ]]; then
    # https://github.com/openai/codex/issues/4620
    eval "$("$brew_command" shellenv)"
    unset brew_command
  fi
fi

(( $+commands[mise] )) && eval "$(mise activate zsh)"
