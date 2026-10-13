#!/usr/bin/env bash
# shellcheck source=tests/helpers.sh
. "$(dirname "$0")/helpers.sh"
if command -v nvim >/dev/null 2>&1; then
  export XDG_CONFIG_HOME="$HOME/.config" XDG_DATA_HOME="$HOME/.local/share"
  export XDG_STATE_HOME="$HOME/.local/state" XDG_CACHE_HOME="$HOME/.cache"
  cat >"$SANDBOX/compile.lua" <<'LUA'
for _, path in ipairs(vim.fn.glob(vim.env.ROOT_CONFIG .. '/**/*.lua', false, true)) do
  local chunk, err = loadfile(path)
  assert(chunk, err)
end
vim.cmd('qa!')
LUA
  ROOT_CONFIG="$ROOT/shared/nvim/.config/nvim" nvim --headless -u NONE -i NONE --noplugin -l "$SANDBOX/compile.lua"
else
  printf 'Neovim Lua syntax smoke skipped: nvim unavailable\n'
fi
# Exercise the actual TPM launch expression with a mock executable and Python.
mkdir -p "$HOME/.tmux/plugins/tpm" "$HOME/.local/share/dotfiles-minimal/tmux-python/bin"
cat >"$HOME/.tmux/plugins/tpm/tpm" <<'MOCK'
#!/bin/bash
[ "$(command -v python)" = "$HOME/.local/share/dotfiles-minimal/tmux-python/bin/python" ]
[ "$(command -v python3)" = "$HOME/.local/share/dotfiles-minimal/tmux-python/bin/python3" ]
MOCK
for interpreter in python python3; do
  printf '#!/bin/bash\nexit 0\n' >"$HOME/.local/share/dotfiles-minimal/tmux-python/bin/$interpreter"
  chmod +x "$HOME/.local/share/dotfiles-minimal/tmux-python/bin/$interpreter"
done
chmod +x "$HOME/.tmux/plugins/tpm/tpm"
expression=$(sed -n "s/^run-shell '\(PATH=.*\)'$/\1/p" "$ROOT/shared/tmux/.tmux.conf")
assert test -n "$expression"
/bin/bash -c "$expression"
