#!/usr/bin/env bash
set -euo pipefail
ROOT=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
# shellcheck source=lib/common.sh
. "$ROOT/lib/common.sh"
[ "$(uname -s)" = Darwin ] || {
  fail 'macOS is required'
  exit 1
}
if ! xcode-select -p >/dev/null 2>&1 || ! xcrun --find clang >/dev/null 2>&1; then
  fail 'Apple Command Line Tools required: run xcode-select --install'
  exit 1
fi
if ! command -v brew >/dev/null 2>&1; then
  for prefix in /opt/homebrew /usr/local; do
    if [ -x "$prefix/bin/brew" ]; then
      export PATH="$prefix/bin:$PATH"
      break
    fi
  done
fi
command -v brew >/dev/null 2>&1 || {
  fail 'Homebrew required; see README bootstrap'
  exit 1
}
brew_environment=$(brew shellenv)
eval "$brew_environment"
export HOMEBREW_NO_AUTO_UPDATE=1 HOMEBREW_NO_INSTALL_CLEANUP=1 HOMEBREW_BUNDLE_NO_UPGRADE=1
if brew bundle check --file="$ROOT/Brewfile" >/dev/null 2>&1; then
  log '✓' 'Homebrew dependencies'
else
  brew bundle install --no-upgrade --file="$ROOT/Brewfile"
  log '+' 'Homebrew dependencies'
fi
# Link complete topic roots; Neovim stays one directory, allowing ignored locals.
for topic in "$ROOT"/shared/*; do
  while IFS= read -r -d '' source; do
    relative=${source#"$topic/"}
    if [ "$relative" = .config/nvim ]; then
      link_file "$source" "$HOME/$relative"
    elif [ -f "$source" ]; then
      link_file "$source" "$HOME/$relative"
    fi
  done < <(find "$topic" -mindepth 1 \( -path '*/.config/nvim' -prune -print0 \) -o -type f -print0)
done
install_plugins
install_python
install_terminfo
log '✓' 'ready; see README for first-launch steps'
