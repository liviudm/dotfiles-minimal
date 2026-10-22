local opt = vim.opt

opt.number = true
opt.relativenumber = true
opt.signcolumn = "yes"
opt.cursorline = true
opt.scrolloff = 8
opt.sidescrolloff = 8
opt.wrap = false

opt.expandtab = true
opt.shiftwidth = 2
opt.tabstop = 2
opt.softtabstop = 2
opt.smartindent = true

opt.ignorecase = true
opt.smartcase = true

opt.termguicolors = true
opt.laststatus = 3
opt.showmode = false
opt.splitbelow = true
opt.splitright = true

opt.mouse = "a"
opt.clipboard = "unnamedplus"

opt.undofile = true
opt.swapfile = false
opt.updatetime = 250
opt.timeoutlen = 400

opt.completeopt = { "menu", "menuone", "noselect" }
opt.shortmess:append("c")

opt.list = true
opt.listchars = { tab = "» ", trail = "·", nbsp = "␣" }

opt.conceallevel = 2
opt.foldlevel = 99
opt.foldlevelstart = 99
opt.foldmethod = "expr"
opt.foldexpr = "v:lua.vim.treesitter.foldexpr()"

vim.g.autoformat = true

-- Helm templates: YAML with Go templating, handled by helm-ls rather than yamlls.
vim.filetype.add({
  pattern = {
    [".*/templates/.*%.ya?ml"] = "helm",
    [".*/templates/.*%.tpl"] = "helm",
    [".*/templates/.*%.txt"] = "helm",
    ["helmfile.*%.ya?ml"] = "helm",
  },
  filename = { ["_helpers.tpl"] = "helm" },
})
