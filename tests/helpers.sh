#!/usr/bin/env bash
set -euo pipefail
ROOT=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
# shellcheck source=lib/common.sh
. "$ROOT/lib/common.sh"
SANDBOX=$(mktemp -d)
trap 'rm -rf "$SANDBOX"' EXIT
export HOME="$SANDBOX/home with spaces"
mkdir -p "$HOME" "$SANDBOX/bin"
assert() { "$@" || {
  printf 'assertion failed: %s\n' "$*" >&2
  exit 1
}; }
