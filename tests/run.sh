#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."
for test in tests/files.sh tests/install.sh tests/launcher.sh tests/terminfo.sh tests/config.sh; do
  /bin/bash "$test"
done
printf 'Behavior checks passed\n'
