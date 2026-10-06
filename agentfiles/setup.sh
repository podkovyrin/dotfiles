#!/bin/sh
# Link the agent config into $HOME with GNU Stow.
# Safe to run again: it restows every package.

set -eu

repo=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
packages="pi agents"

for tool in stow jq; do
    if ! command -v "$tool" >/dev/null 2>&1; then
        echo "error: $tool is not installed (macOS: brew install $tool; Omarchy: omarchy pkg add $tool)" >&2
        exit 1
    fi
done

# These directories must be real directories. If they do not exist, stow
# links the full directory to this repo, and pi then writes auth.json,
# sessions, and caches into the repo.
mkdir -p "$HOME/.pi/agent" "$HOME/.agents"

git -C "$repo" config filter.pi-settings.clean \
    "jq --indent 2 'del(.deviceId, .trackingId, .lastChangelogVersion)'"
git -C "$repo" config filter.pi-settings.smudge cat

# shellcheck disable=SC2086
stow --dir "$repo" --target "$HOME" --restow $packages

echo "Linked: $packages"
echo "Next: pi update --extensions, then start pi and run /login"
