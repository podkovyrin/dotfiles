#!/bin/sh

set -eu

script_dir=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)

case $(uname -s) in
    Darwin)
        exec "$script_dir/setup-darwin.sh" "$@"
        ;;
    Linux)
        exec "$script_dir/setup-linux.sh" "$@"
        ;;
    *)
        echo "Unsupported operating system: $(uname -s)" >&2
        exit 1
        ;;
esac
