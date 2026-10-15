local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local lazyrepo = "https://github.com/folke/lazy.nvim.git"
  local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
  if vim.v.shell_error ~= 0 then
    vim.api.nvim_echo({
      { "Failed to clone lazy.nvim:\n", "ErrorMsg" },
      { out, "WarningMsg" },
      { "\nPress any key to exit..." },
    }, true, {})
    vim.fn.getchar()
    os.exit(1)
  end
end
vim.opt.rtp:prepend(lazypath)

-- Keep Lazy's writable lock outside the symlinked repository.
local baseline = vim.fn.readfile(vim.fn.stdpath("config") .. "/lazy-lock.json")
local state = vim.fn.stdpath("state")
local lockfile = state .. "/lazy-lock.json"
local baseline_stamp = state .. "/lazy-lock.baseline.sha256"
local digest = vim.fn.sha256(table.concat(baseline, "\n"))
local previous = vim.fn.filereadable(baseline_stamp) == 1 and vim.fn.readfile(baseline_stamp)[1] or nil
vim.fn.mkdir(state, "p")
if vim.fn.filereadable(lockfile) == 0 or previous ~= digest then
  if vim.fn.filereadable(lockfile) == 1 then
    local backup = lockfile .. ".bak"
    local suffix = 0
    while (vim.uv or vim.loop).fs_lstat(backup) do
      suffix = suffix + 1
      backup = lockfile .. ".bak." .. suffix
    end
    assert(vim.fn.rename(lockfile, backup) == 0, "Cannot back up Lazy lockfile")
  end
  assert(vim.fn.writefile(baseline, lockfile) == 0, "Cannot seed Lazy lockfile")
  assert(vim.fn.writefile({ digest }, baseline_stamp) == 0, "Cannot record Lazy baseline")
end
-- End runtime lock initialization.

require("lazy").setup({
  lockfile = lockfile,
  spec = { { import = "plugins" } },
  install = { colorscheme = { "dracula" } },
  checker = { enabled = false },
  change_detection = { notify = false },
  performance = {
    rtp = {
      disabled_plugins = {
        "gzip", "tarPlugin", "tohtml", "tutor", "zipPlugin", "netrwPlugin",
      },
    },
  },
})
