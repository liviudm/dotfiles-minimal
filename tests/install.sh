#!/usr/bin/env bash
# shellcheck source=tests/helpers.sh
. "$(dirname "$0")/helpers.sh"
# Exercise a standalone copy at an arbitrary checkout path containing spaces.
relocated="$SANDBOX/another checkout with spaces"
mkdir -p "$relocated"
cp "$ROOT/install.sh" "$ROOT/Brewfile" "$relocated/"
cp -R "$ROOT/lib" "$ROOT/shared" "$relocated/"
ROOT="$relocated"
export PATH="$SANDBOX/bin:/usr/bin:/bin:/usr/sbin:/sbin"
export MOCK_STATE="$SANDBOX/state"
mkdir "$MOCK_STATE"
cat >"$SANDBOX/bin/uname" <<'MOCK'
#!/bin/bash
printf '%s\n' "${MOCK_OS:-Darwin}"
MOCK
cat >"$SANDBOX/bin/xcode-select" <<'MOCK'
#!/bin/bash
[ "${MOCK_CLT_FAIL:-0}" = 0 ]
MOCK
cp "$SANDBOX/bin/xcode-select" "$SANDBOX/bin/xcrun"
# Missing prerequisites must stop before linking or installing anything.
chmod +x "$SANDBOX/bin/"*
if MOCK_OS=Linux /bin/bash "$ROOT/install.sh" >"$SANDBOX/log" 2>&1; then exit 1; fi
assert /usr/bin/grep -q 'macOS is required' "$SANDBOX/log"
if MOCK_CLT_FAIL=1 /bin/bash "$ROOT/install.sh" >"$SANDBOX/log" 2>&1; then exit 1; fi
mkdir -p "$SANDBOX/without brew/lib"
cp "$ROOT/lib/common.sh" "$SANDBOX/without brew/lib/"
sed 's|/opt/homebrew /usr/local|/nonexistent-homebrew /nonexistent-local|' "$ROOT/install.sh" >"$SANDBOX/without brew/install.sh"
if /bin/bash "$SANDBOX/without brew/install.sh" >"$SANDBOX/log" 2>&1; then exit 1; fi
assert /usr/bin/grep -q 'Homebrew required' "$SANDBOX/log"
cat >"$SANDBOX/bin/brew" <<'MOCK'
#!/bin/bash
case "$*" in
  shellenv) [ "${MOCK_SHELLENV_FAIL:-0}" = 0 ] ;;
  'bundle check'*) test -f "$MOCK_STATE/brew" ;;
  'bundle install'*)
    [ "${MOCK_BREW_FAIL:-0}" = 0 ] || exit 7
    [[ "$*" = *--no-upgrade* ]] || exit 9
    touch "$MOCK_STATE/brew" ;;
  *) exit 8 ;;
esac
MOCK
cat >"$SANDBOX/bin/git" <<'MOCK'
#!/bin/bash
if [ "$1" = clone ]; then
  [ "${MOCK_GIT_FAIL:-0}" = 0 ] || exit 6
  for arg in "$@"; do previous=${target:-}; target=$arg; done
  mkdir -p "$target/.git"
  printf '%s\n' "$previous" > "$target/.git/origin"
else
  cat "$2/.git/origin"
fi
MOCK
cat >"$SANDBOX/bin/python3" <<'MOCK'
#!/bin/bash
[ "$1 $2" = '-m venv' ] || exit 4
mkdir -p "$3/bin"
touch "$3/pyvenv.cfg"
cat > "$3/bin/python" <<'PYTHON'
#!/bin/bash
if [ "$1" = -c ]; then test -f "$MOCK_STATE/libtmux"; else
  [ "${MOCK_PIP_FAIL:-0}" = 0 ] || exit 5
  touch "$MOCK_STATE/libtmux"
fi
PYTHON
chmod +x "$3/bin/python"
ln -s python "$3/bin/python3"
MOCK
cat >"$SANDBOX/bin/infocmp" <<'MOCK'
#!/bin/bash
exit 0
MOCK
chmod +x "$SANDBOX/bin/"*
if MOCK_SHELLENV_FAIL=1 /bin/bash "$ROOT/install.sh" >"$SANDBOX/log" 2>&1; then exit 1; fi
assert test ! -e "$HOME/.gitconfig"
if MOCK_BREW_FAIL=1 /bin/bash "$ROOT/install.sh" >"$SANDBOX/log" 2>&1; then exit 1; fi
assert test ! -e "$HOME/.gitconfig"
# Seed existing host configurations before the first run that reaches linking.
for relative in .gitconfig .zshrc .zprofile .tmux.conf .config/starship.toml .local/bin/ghostty-tmux 'Library/Application Support/com.mitchellh.ghostty/config.ghostty'; do
  mkdir -p "$(dirname "$HOME/$relative")"
  printf 'original %s\n' "$relative" >"$HOME/$relative"
done
printf older >"$HOME/.zshrc.dotfiles-minimal.bak"
mkdir -p "$HOME/.config/nvim/old plugins"
printf personal >"$HOME/.config/nvim/old plugins/settings.lua"
if MOCK_GIT_FAIL=1 /bin/bash "$ROOT/install.sh" >"$SANDBOX/log" 2>&1; then exit 1; fi
assert test ! -e "$HOME/.oh-my-zsh"
for relative in .gitconfig .zprofile .tmux.conf .config/starship.toml .local/bin/ghostty-tmux 'Library/Application Support/com.mitchellh.ghostty/config.ghostty'; do
  assert test "$(cat "$HOME/$relative.dotfiles-minimal.bak")" = "original $relative"
  assert test -L "$HOME/$relative"
done
assert test "$(cat "$HOME/.zshrc.dotfiles-minimal.bak")" = older
assert test "$(cat "$HOME/.zshrc.dotfiles-minimal.bak.1")" = 'original .zshrc'
assert test "$(cat "$HOME/.config/nvim.dotfiles-minimal.bak/old plugins/settings.lua")" = personal

if MOCK_PIP_FAIL=1 /bin/bash "$ROOT/install.sh" >"$SANDBOX/log" 2>&1; then exit 1; fi
/bin/bash "$ROOT/install.sh" >"$SANDBOX/log" 2>&1
/bin/bash "$ROOT/install.sh" >"$SANDBOX/log" 2>&1
if /usr/bin/grep -Ev '^  ✓ ' "$SANDBOX/log"; then exit 1; fi
assert test -L "$HOME/.config/nvim"
assert test -L "$HOME/Library/Application Support/com.mitchellh.ghostty/config.ghostty"
assert test -x "$HOME/.local/share/dotfiles-minimal/tmux-python/bin/python3"
assert test -d "$HOME/.tmux/plugins/tmux-window-name/.git"

# Converged runs must not create duplicate backups.
assert test ! -e "$HOME/.zshrc.dotfiles-minimal.bak.2"
assert test ! -e "$HOME/.config/nvim.dotfiles-minimal.bak.1"
