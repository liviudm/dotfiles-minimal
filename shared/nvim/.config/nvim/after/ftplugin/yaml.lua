vim.keymap.set("n", "<localleader>ys", function()
  require("yaml-companion").open_ui_select()
end, { buffer = true, desc = "YAML schema picker" })
