#!/bin/sh

#
# Based on https://github.com/aaronoah/clean-my-mac
#
#
# MIT License
#
# Copyright (c) 2018 Hanqing Zhao
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.
#

source "$HOME/.dotfiles/scripts/clean_my_mac/targets.sh"


clean_my_mac() {

  detect_shell() {
    if [ -n "$BASH_VERSION" ]; then
      echo "bash"
    elif [ -n "$ZSH_VERSION" ]; then
      echo "zsh"
    elif [ -n "$FISH_VERSION" ]; then
      echo "fish"
    else
      echo "unknown"
    fi
  }

  local colors
  local RED
  local BLUE
  local GREEN
  local YELLOW
  local NORMAL
  if which tput >/dev/null 2>&1; then
    colors=$(tput colors)
  fi

  if [[ -n "$colors" ]] && [[ "$colors" -ge 8 ]]; then
    RED="$(tput setaf 1)"
    BLUE="$(tput setaf 4)"
    GREEN="$(tput setaf 6)"
    YELLOW="$(tput setaf 3)"
    NORMAL="$(tput sgr0)"
  else
    RED=""
    BLUE=""
    GREEN=""
    YELLOW=""
    NORMAL=""
  fi

  set -f # disable globbing

  local CLEAN_TARGETS=$(targets)
  local TARGETS=( $(echo $CLEAN_TARGETS | tr ':' ' ') )

  for target in ${TARGETS[@]}; do
    set +f
    local shell_type=$(detect_shell)
    
    if [ "$shell_type" = "zsh" ]; then
      target=${~target}
    elif [ "$shell_type" = "fish" ]; then
      target=$(eval echo $target)
    fi

    if [ $(command find $target 2>/dev/null | wc -l) -eq 0 ]; then
      continue
    fi
    
    printf "${GREEN}Estimating size of $target ... "
    space=$(command du -ch $target | tail -n 1 | cut -f 1)

    printf "$space.${NORMAL}\n"
    printf "${BLUE}Removing $target ... "
    rm -rf $target >/dev/null 2>&1 || {
      printf "${RED}Error removing $target.${NORMAL}\n"
    }

    printf "${BLUE}done.\n"
    printf "${NORMAL}"
    set -f
  done

  printf "Removing unavailable simulators..."
  xcrun simctl delete unavailable

  set +f

  local SYSTEM_CACHES="/tmp, /var, /private"
  printf "\n${YELLOW}If you wish to optimize your system caches in $SYSTEM_CACHES, reboot your Mac\n"
  printf "${YELLOW}Don't manually delete ANY files in there, it could crash your Mac\n${NORMAL}"
  # DON'T EVER TRY MANUALLY DELETE SYSTEM FOLDERS, YOUR MAC MIGHT GET INTO TROUBLE!!
  # reboot to let Max OSX itself clear out junk files in /tmp, /private and /var,
  # if things still don't work out, try reboot Mac into safe mode, see http://osxdaily.com/2010/04/20/using-safe-boot-mode-in-mac-os-x/

}

clean_my_mac
