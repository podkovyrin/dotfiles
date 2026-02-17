#!/usr/bin/env bash
set -euo pipefail

CONFIG_PATH="${AEROSPACE_CONFIG_PATH:-$HOME/.aerospace.toml}"
if [[ $# -gt 0 ]]; then
  CONFIG_PATH="$1"
fi

if [[ ! -f "$CONFIG_PATH" ]]; then
  echo "AeroSpace config not found at: ${CONFIG_PATH}" >&2
  exit 1
fi

NEW_VALUE="$(
python3 - "$CONFIG_PATH" 200 <<'PY'
import sys
import re
from pathlib import Path

config_path = Path(sys.argv[1])
gap = int(sys.argv[2])
text = config_path.read_text()

def pattern_for(side: str) -> re.Pattern:
    return re.compile(
        r'(outer\.' + side + r'\s*=\s*\[\{\s*monitor\."dell"\s*=\s*)(\d+)(\s*\},\s*0\s*\])',
        re.IGNORECASE,
    )

patterns = {side: pattern_for(side) for side in ('left', 'right')}
matches = {side: patterns[side].search(text) for side in patterns}

missing = [side for side, match in matches.items() if match is None]
if missing:
    print(f"Missing Dell gap entry for outer.{', '.join(missing)}", file=sys.stderr)
    sys.exit(1)

current = int(matches['left'].group(2))
target = 0 if current != 0 else gap

def apply(pattern: re.Pattern, content: str) -> str:
    def repl(match: re.Match) -> str:
        return f"{match.group(1)}{target}{match.group(3)}"

    updated, count = pattern.subn(repl, content, count=1)
    if count != 1:
        print("Failed to update AeroSpace gaps", file=sys.stderr)
        sys.exit(1)
    return updated

for side in ('left', 'right'):
    text = apply(patterns[side], text)

config_path.write_text(text)
print(target)
PY
)"

if [[ -z "${NEW_VALUE}" ]]; then
  echo "Failed to determine new gap value" >&2
  exit 1
fi

if ! command -v aerospace >/dev/null 2>&1; then
  echo "'aerospace' CLI not found in PATH" >&2
  exit 1
fi

echo "Set Dell outer gaps to ${NEW_VALUE}px"
aerospace reload-config >/dev/null
