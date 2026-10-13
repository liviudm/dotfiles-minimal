#!/usr/bin/env bash
# shellcheck source=tests/helpers.sh
. "$(dirname "$0")/helpers.sh"
export PATH="$SANDBOX/bin:/usr/bin:/bin"
export GHOSTTY_TMUX_EXTRA_PATH="$SANDBOX/bin"
mkdir -p "$HOME/.local/share/dotfiles-minimal/tmux-python/bin"
export MOCK_LOG="$SANDBOX/commands"
export SHELL="$SANDBOX/bin/shell"
cat >"$SHELL" <<'MOCK'
#!/bin/bash
printf 'shell %s\n' "$*" >> "$MOCK_LOG"
MOCK
cat >"$SANDBOX/bin/tmux" <<'MOCK'
#!/bin/bash
if [ "$1" = list-sessions ]; then
  printf '%s' "${MOCK_SESSIONS:-}"
else
  printf 'tmux %s\n' "$*" >> "$MOCK_LOG"
fi
MOCK
cat >"$SANDBOX/bin/fzf" <<'MOCK'
#!/bin/bash
cat >/dev/null
printf '%s' "${MOCK_CHOICE:-}"
MOCK
chmod +x "$SANDBOX/bin/"*
launcher="$ROOT/shared/ghostty/.local/bin/ghostty-tmux"
TMUX=nested /bin/bash "$launcher"
assert test "$(cat "$MOCK_LOG")" = 'shell -l'
: >"$MOCK_LOG"
TMUX='' /bin/bash "$launcher"
assert test "$(cat "$MOCK_LOG")" = 'tmux new-session -A -s main'
: >"$MOCK_LOG"
TMUX='' MOCK_SESSIONS=work MOCK_CHOICE=work /bin/bash "$launcher"
assert /usr/bin/grep -Fq "tmux set-environment -g PATH $HOME/.local/share/dotfiles-minimal/tmux-python/bin:" "$MOCK_LOG"
assert /usr/bin/grep -q '^tmux attach-session -t work$' "$MOCK_LOG"
: >"$MOCK_LOG"
TMUX='' MOCK_SESSIONS=work /bin/bash "$launcher"
assert /usr/bin/grep -q '^shell -l$' "$MOCK_LOG"
: >"$MOCK_LOG"
TMUX='' MOCK_SESSIONS=work MOCK_CHOICE='New Session' /bin/bash "$launcher"
assert /usr/bin/grep -q '^tmux new-session -s New Session$' "$MOCK_LOG"
rm "$SANDBOX/bin/tmux"
: >"$MOCK_LOG"
TMUX='' /bin/bash "$launcher"
assert test "$(cat "$MOCK_LOG")" = 'shell -l'
