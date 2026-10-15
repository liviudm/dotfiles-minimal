return {
  {
    "Mofiqul/dracula.nvim",
    lazy = false,
    priority = 1000,
    opts = {},
    config = function(_, opts)
      require("dracula").setup(opts)
      vim.cmd.colorscheme("dracula")
    end,
  },
  {
    "catppuccin/nvim",
    name = "catppuccin",
    lazy = true,
    opts = { flavour = "mocha" },
  },
}
