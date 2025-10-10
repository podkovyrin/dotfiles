eval "$(/opt/homebrew/bin/brew shellenv)"
eval "$(mise activate zsh)"

export MANPATH="/opt/homebrew/share/man:$MANPATH"
export INFOPATH="/opt/homebrew/share/info:$INFOPATH"

export BOOST_ROOT=/opt/homebrew/opt/boost
export ANDROID_HOME="$HOME/Library/Android/sdk"

export JAVA_HOME="$(/usr/libexec/java_home)"

export PATH="/Applications/Sublime Text.app/Contents/SharedSupport/bin:$PATH"
export PATH="$HOME/.mint/bin:$PATH"
export PATH="$ANDROID_HOME/platform-tools:$PATH"
export PATH="$ANDROID_HOME/cmdline-tools/latest/bin:$PATH"

# LLVM via Homebrew
export PATH="/opt/homebrew/opt/llvm/bin:$PATH"
export LDFLAGS="-L/opt/homebrew/opt/llvm/lib"
export CPPFLAGS="-I/opt/homebrew/opt/llvm/include"
export CMAKE_PREFIX_PATH="/opt/homebrew/opt/llvm"

[ -e ~/.secrets ] && source ~/.secrets
