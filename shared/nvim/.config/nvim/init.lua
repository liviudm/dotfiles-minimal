vim.g.mapleader = " "
vim.g.maplocalleader = ","

require("config.options")
require("config.keymaps")
require("config.autocmds")
require("config.lazy")

pcall(dofile, vim.fn.stdpath("config") .. "/init.local.lua")
