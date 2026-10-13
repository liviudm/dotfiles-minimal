return {
  {
    "folke/which-key.nvim",
    event = "VeryLazy",
    opts = {
      preset = "modern",
      spec = {
        { "<leader>b", group = "buffer" },
        { "<leader>f", group = "find" },
        { "<leader>g", group = "git" },
        { "<leader>h", group = "hunk" },
        { "<leader>l", group = "lsp" },
        { "<leader>u", group = "toggle" },
        { "<leader>w", group = "window" },
        { "<leader>x", group = "trouble" },
        { ",m", group = "markdown" },
        { ",y", group = "yaml" },
      },
    },
    keys = {
      { "<leader>?", function() require("which-key").show({ global = true }) end, desc = "Which-key show" },
    },
  },
}
