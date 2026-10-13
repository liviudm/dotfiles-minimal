vim.opt_local.wrap = true
vim.opt_local.linebreak = true
vim.opt_local.spell = true
vim.opt_local.conceallevel = 2

local map = function(lhs, rhs, desc)
  vim.keymap.set("n", lhs, rhs, { buffer = true, desc = desc })
end
map("<localleader>mr", "<cmd>RenderMarkdown toggle<cr>", "Toggle render-markdown")
map("<localleader>mc", "<cmd>RenderMarkdown config<cr>", "Re-config render-markdown")
