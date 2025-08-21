#!/bin/zsh

#
# macOS Dev toolchain update
# Keeps Homebrew, language stacks, IDE bits, containers, and system up-to-date.
# Safe-by-default; destructive cleanups are behind --aggressive.
#
# Usage:
#   ./toolchain_update.sh                # full run (incl. macOS & App Store updates)
#   ./toolchain_update.sh --dry-run      # print what would run
#   ./toolchain_update.sh --aggressive   # add heavy cleanups (docker prune, caches, etc.)
#   ./toolchain_update.sh --include-os-update   # include macOS softwareupdate
#

set -o pipefail
IFS=$'\n\t'

# ---------- flags ----------
AGGRESSIVE=0
INCLUDE_OS_UPDATE=0
DRY_RUN=0

while [[ $# -gt 0 ]]; do
  case "$1" in
    --aggressive) AGGRESSIVE=1 ;;
    --include-os-update) INCLUDE_OS_UPDATE=1 ;;
    --dry-run) DRY_RUN=1 ;;
    -*)
      echo "Unknown flag: $1" >&2
      exit 2
      ;;
  esac
  shift
done

# ---------- logging ----------
# Check if we're already in a script session to avoid infinite recursion
if [[ -z "$SCRIPT_SESSION" ]]; then
    export SCRIPT_SESSION=1
    STAMP="$(date +%F_%H-%M-%S)"
    LOGDIR="${HOME}/Library/Logs"
    LOGFILE="${LOGDIR}/toolchain_update-${STAMP}.log"
    mkdir -p "${LOGDIR}"
    exec script -q "${LOGFILE}" "$0" "$@"
    exit $?
fi

# If we reach here, we're in the script session - no additional logging setup needed
STAMP="$(date +%F_%H-%M-%S)"
LOGDIR="${HOME}/Library/Logs"
LOGFILE="${LOGDIR}/toolchain_update-${STAMP}.log"

# ---------- utils ----------
BLUE="\033[1;34m"; GREEN="\033[1;32m"; YELLOW="\033[1;33m"; RED="\033[1;31m"; NC="\033[0m"
log()  { printf "\n${BLUE}==> %s${NC}\n" "$*"; }
ok()   { printf "${GREEN}[ok]${NC} %s\n" "$*"; }
warn() { printf "${YELLOW}[warn]${NC} %s\n" "$*" >&2; }
err()  { printf "${RED}[err]${NC} %s\n" "$*" >&2; }
has()  { command -v "$1" >/dev/null 2>&1; }

run() {
  log "$*"
  if [[ "${DRY_RUN}" -eq 1 ]]; then
    echo "(dry-run) $*"
    return 0
  fi
  eval "$@"
  local rc=$?
  if [[ $rc -ne 0 ]]; then warn "command failed (rc=$rc): $*"; fi
  return $rc
}

# ---------- Environment bootstrap ----------

if [ -n "$ZSH_VERSION" ]; then
  source "${HOME}/.zshrc" > /dev/null
else
  # Avoid sourcing interactive shell rc files (e.g., .zshrc) inside bash to prevent cross-shell syntax errors.
  # Instead, directly bootstrap common tool shims when present.

  # NVM (if installed but not loaded)
  if [[ -z "$(command -v nvm)" && -d "${HOME}/.nvm" && -f "${HOME}/.nvm/nvm.sh" ]]; then
    source "${HOME}/.nvm/nvm.sh"
  fi

  # asdf (if installed but not loaded)
  if [[ -z "$(command -v asdf)" && -f "${HOME}/.asdf/asdf.sh" ]]; then
    source "${HOME}/.asdf/asdf.sh"
  fi
fi

log "System info"
if has fastfetch; then
  fastfetch || true
else
  sw_vers  || true
  uname -mr || true
fi

# ---------- Homebrew core ----------
if ! has brew; then
  err "Homebrew not found. Install from https://brew.sh and re-run."
  exit 1
fi

BREW="$(command -v brew)"
log "Homebrew at ${BREW}"
run "brew update"
run "brew upgrade"
run "brew upgrade --cask"
run "brew cleanup"
run "brew autoremove"
run "brew doctor"

# ---------- App Store (mas) ----------
if has mas; then
  log "Updating Mac App Store apps (mas)"
  run "mas upgrade"
else
  warn "'mas' not installed (brew install mas) — skipping App Store updates"
fi

# ---------- macOS software updates ----------
if [[ "${INCLUDE_OS_UPDATE}" -eq 1 ]]; then
  log "Checking for macOS updates (may prompt for sudo)"
  run "sudo softwareupdate -ia --verbose"
else
  warn "Skipping macOS softwareupdate (per flag)"
fi

# ---------- Xcode / CLT maintenance ----------
if has xcodebuild; then
  log "Xcode info"
  xcodebuild -version || true
  run "xcrun simctl delete unavailable"  # prune dead simulators
fi
if has xcode-select; then
  DEVELOPER_DIR="$(xcode-select -p 2>/dev/null || true)"
  [[ -n "$DEVELOPER_DIR" ]] && ok "Active developer dir: $DEVELOPER_DIR"
fi

# ---------- Node.js ecosystem ----------
if has node; then
  log "Node.js global updates"
  node -v || true
  if has npm;   then run "npm -g update"; fi
  if has yarn;  then run "yarn global upgrade || true"; fi
  if has pnpm;  then run "pnpm update -g --latest || pnpm update -g || true"; fi
  if has bun;   then run "bun upgrade"; fi
else
  warn "Node.js not found — skipping npm/yarn/pnpm/bun updates"
fi

# ---------- Python ecosystem ----------
if has python3; then
  log "Python3 info"
  python3 --version || true
fi
if has pipx; then
  log "pipx updates"
  run "pipx upgrade-all"
fi
# Safe optional: upgrade user-site pip packages (disabled by default)
if [[ "${AGGRESSIVE}" -eq 1 && "$(command -v pip3)" ]]; then
  log "Upgrading user-installed pip packages (aggressive)"
  run "python3 -m pip list --user --outdated --format=freeze | cut -d'=' -f1 | xargs -n1 -I{} python3 -m pip install --user -U {}"
fi
if has pyenv; then
  log "pyenv maintenance"
  run "pyenv update"
fi
if has conda; then
  log "Conda updates"
  run "conda update -n base -c defaults conda -y"
  run "conda update --all -y"
fi

# ---------- Ruby ecosystem ----------
# if has gem; then
#   log "RubyGems updates"
#   run "gem update --system"
#   run "gem update"
# fi
# if has rbenv; then
#   ok "rbenv detected — consider 'rbenv install -l' and installing latest patch for your current major.minor"
# fi

# ---------- Rust ecosystem ----------
if has rustup; then
  log "Rustup toolchains"
  run "rustup self update"
  run "rustup update"
fi

# ---------- asdf ----------
if has asdf; then
  log "asdf maintenance"
  run "asdf update"
  run "asdf plugin update --all"
  # 'asdf install' would (re)install versions from .tool-versions if present in cwd
fi

# ---------- iOS/Pods ----------
if has pod; then
  log "CocoaPods specs repo update"
  run "pod repo update"
fi

# ---------- zimfw ----------
if has zimfw; then
  log "Zimfw update"
  run "zimfw upgrade"
  run "zimfw update"
fi

# ---------- Flutter ----------
if has flutter; then
  log "Flutter SDK upgrade"
  run "flutter upgrade"
fi

# ---------- Containers (Docker/Podman) ----------
if has docker; then
  log "Docker info"
  docker --version || true
  if [[ "${AGGRESSIVE}" -eq 1 ]]; then
    log "Docker prune (aggressive)"
    run "docker system prune -af --volumes"
    run "docker builder prune -af"
  fi
fi
if has podman; then
  log "Podman info"
  podman --version || true
  if [[ "${AGGRESSIVE}" -eq 1 ]]; then
    log "Podman prune (aggressive)"
    run "podman system prune -af"
  fi
fi

# ---------- Caches (aggressive) ----------
if [[ "${AGGRESSIVE}" -eq 1 ]]; then
  if has npm;  then run "npm cache verify || npm cache clean --force"; fi
  if has yarn; then run "yarn cache clean || true"; fi
  if has pnpm; then run "pnpm store prune || true"; fi
fi

# ---------- Security posture checks (read-only) ----------
log "Security posture (read-only checks)"
spctl --status || true
if has fdesetup; then fdesetup status || true; fi
if [[ $EUID -eq 0 ]]; then
  /usr/libexec/ApplicationFirewall/socketfilterfw --getglobalstate || true
else
  warn "Firewall status requires sudo: sudo /usr/libexec/ApplicationFirewall/socketfilterfw --getglobalstate"
fi

ok "Done. Full log at ${LOGFILE}"
if [[ "${SKIP_OS_UPDATE}" -eq 0 ]]; then
  echo "Note: If macOS updates were installed, a reboot may be required."
fi
