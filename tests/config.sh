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
local requested
package.preload['nvim-treesitter'] = function()
  return { install = function(parsers) requested = parsers end }
end
dofile(vim.env.ROOT_CONFIG .. '/lua/plugins/treesitter.lua')[1].config()
assert(vim.treesitter.language.get_lang('jsonc') == 'json', 'JSONC must use JSON parser')
assert(vim.tbl_contains(requested, 'json'), 'JSON parser must be installed')
assert(not vim.tbl_contains(requested, 'jsonc'), 'JSONC is not an installable parser')
-- Exercise the real bootstrap without downloading/loading Lazy plugins.
vim.fn.mkdir(vim.fn.stdpath('data') .. '/lazy/lazy.nvim', 'p')
vim.fn.mkdir(vim.fn.stdpath('config'), 'p')
local tracked = vim.fn.stdpath('config') .. '/lazy-lock.json'
local initial = { '{"example":{"commit":"baseline"}}' }
vim.fn.writefile(initial, tracked)
local options
package.preload.lazy = function() return { setup = function(opts) options = opts end } end
local bootstrap = vim.env.ROOT_CONFIG .. '/lua/config/lazy.lua'
dofile(bootstrap)
local runtime = options.lockfile
assert(runtime == vim.fn.stdpath('state') .. '/lazy-lock.json')
assert(vim.deep_equal(vim.fn.readfile(runtime), initial))
vim.fn.writefile({ 'local update' }, runtime)
dofile(bootstrap)
assert(vim.fn.readfile(runtime)[1] == 'local update', 'unchanged baseline must preserve local state')
vim.fn.writefile({ 'existing backup' }, runtime .. '.bak')
vim.fn.writefile({ '{"example":{"commit":"new-baseline"}}' }, tracked)
dofile(bootstrap)
assert(vim.fn.readfile(runtime .. '.bak.1')[1] == 'local update')
assert(vim.fn.readfile(runtime .. '.bak')[1] == 'existing backup')
assert(vim.deep_equal(vim.fn.readfile(runtime), vim.fn.readfile(tracked)))
assert(vim.fn.readfile(tracked)[1] == '{"example":{"commit":"new-baseline"}}')
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
