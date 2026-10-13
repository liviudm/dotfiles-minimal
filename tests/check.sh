#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."
command -v shellcheck >/dev/null
command -v shfmt >/dev/null
while IFS= read -r -d '' file; do
  /bin/bash -n "$file"
  shellcheck -x "$file"
  shfmt -d -i 2 -ci "$file"
done < <(find install.sh lib tests -type f -name '*.sh' -print0)
/bin/bash -n shared/ghostty/.local/bin/ghostty-tmux
shellcheck shared/ghostty/.local/bin/ghostty-tmux
shfmt -d -i 2 -ci shared/ghostty/.local/bin/ghostty-tmux
for file in shared/zsh/.zshrc shared/zsh/.zprofile; do
  zsh -n "$file"
done
bash tests/run.sh
if git rev-parse --git-dir >/dev/null 2>&1; then
  git diff --check
else
  printf 'No Git metadata; checking file whitespace directly\n'
fi
# Also check newly created files, which git diff omits before staging.
if rg -n '[ \t]+$' --glob '!*.lua' --glob '!*.toml' --glob '!lazy-lock.json' --hidden --glob '!.git/**' .; then
  printf 'Trailing whitespace found\n' >&2
  exit 1
fi
printf 'All checks passed\n'
