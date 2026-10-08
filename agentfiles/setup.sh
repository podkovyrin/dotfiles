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

# pi-subagent-manager rejects symlinked settings, so copy instead of linking.
# A differing local copy (for example, saved from /agents) is kept as .bak.
copy_settings() {
    src="$repo/copied/$1"
    dest="$2"
    mkdir -p "$(dirname -- "$dest")"
    if [ -f "$dest" ] && ! cmp -s "$src" "$dest"; then
        cp -p "$dest" "$dest.bak"
        echo "Backed up $dest to $dest.bak"
    fi
    install -m 600 "$src" "$dest"
}
copy_settings pi-subagent-manager/settings.json \
    "$HOME/.pi/agent/subagent-manager/settings.json"

echo "Linked: $packages"
echo "Next: pi update --extensions, then start pi and run /login"
