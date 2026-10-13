#!/usr/bin/env bash
# shellcheck source=tests/helpers.sh
. "$(dirname "$0")/helpers.sh"
infocmp() {
  if [ "$1" = -A ]; then
    printf 'entry\n'
    return
  fi
  [ "$(cat "$HOME/.terminfo/78/xterm-ghostty" 2>/dev/null)" = compiled ]
}
tic() {
  cat >/dev/null
  [ "${MOCK_TIC_FAIL:-0}" = 0 ] || return 1
  mkdir -p "$3/78"
  printf compiled >"$3/78/xterm-ghostty"
}
# Always exercise compilation, independently of live Ghostty installation.
export GHOSTTY_APP="$SANDBOX/custom apps/Ghostty.app"
mkdir -p "$GHOSTTY_APP/Contents/Resources/terminfo"
assert test "$(ghostty_terminfo_db)" = "$GHOSTTY_APP/Contents/Resources/terminfo"
if (
  GHOSTTY_APP="$SANDBOX/missing"
  ghostty_terminfo_db
); then exit 1; fi
if (
  MOCK_TIC_FAIL=1
  install_terminfo
); then exit 1; fi
assert test ! -e "$HOME/.terminfo/78/xterm-ghostty"
mkdir -p "$HOME/.terminfo/78"
printf broken >"$HOME/.terminfo/78/xterm-ghostty"
install_terminfo
assert test "$(cat "$HOME/.terminfo/78/xterm-ghostty.dotfiles-minimal.bak")" = broken
assert test "$(install_terminfo)" = '  ✓ xterm-ghostty terminfo'
unset GHOSTTY_APP
mkdir -p "$HOME/Applications/Ghostty.app/Contents/Resources/terminfo"
assert test "$(ghostty_terminfo_db)" = "$HOME/Applications/Ghostty.app/Contents/Resources/terminfo"
