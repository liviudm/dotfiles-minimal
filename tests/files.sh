#!/usr/bin/env bash
# shellcheck source=tests/helpers.sh
. "$(dirname "$0")/helpers.sh"
printf original >"$HOME/file name"
printf older >"$HOME/file name.dotfiles-minimal.bak"
ln -s missing "$HOME/file name.dotfiles-minimal.bak.1"
printf managed >"$SANDBOX/source file"
link_file "$SANDBOX/source file" "$HOME/file name"
assert test "$(cat "$HOME/file name.dotfiles-minimal.bak.2")" = original
assert test "$(link_file "$SANDBOX/source file" "$HOME/file name")" = "  ✓ $HOME/file name"
mkdir "$HOME/directory"
printf content >"$HOME/directory/content"
link_file "$SANDBOX/source file" "$HOME/directory"
assert test -f "$HOME/directory.dotfiles-minimal.bak/content"
ln -s missing "$HOME/unexpected"
if link_file "$SANDBOX/source file" "$HOME/unexpected"; then exit 1; fi
assert test "$(readlink "$HOME/unexpected")" = missing
ln -s "$SANDBOX" "$HOME/parent"
if link_file "$SANDBOX/source file" "$HOME/parent/new"; then exit 1; fi
assert test ! -e "$SANDBOX/new"

# Failure to move an original must stop linking and leave its bytes intact.
printf precious >"$HOME/cannot back up"
mv() { return 1; }
if link_file "$SANDBOX/source file" "$HOME/cannot back up"; then exit 1; fi
assert test ! -L "$HOME/cannot back up"
assert test "$(cat "$HOME/cannot back up")" = precious
unset -f mv
