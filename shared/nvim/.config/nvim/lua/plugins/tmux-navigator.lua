return {
  {
    "christoomey/vim-tmux-navigator",
    cmd = {
      "TmuxNavigateLeft",
      "TmuxNavigateDown",
      "TmuxNavigateUp",
      "TmuxNavigateRight",
      "TmuxNavigatePrevious",
    },
    keys = {
      { "<C-h>", "<cmd>TmuxNavigateLeft<cr>" },
      { "<C-j>", "<cmd>TmuxNavigateDown<cr>" },
      { "<C-k>", "<cmd>TmuxNavigateUp<cr>" },
      { "<C-l>", "<cmd>TmuxNavigateRight<cr>" },
      { "<C-\\>", "<cmd>TmuxNavigatePrevious<cr>" },
      { "<C-h>", "<C-\\><C-n><cmd>TmuxNavigateLeft<cr>", mode = "t" },
      { "<C-j>", "<C-\\><C-n><cmd>TmuxNavigateDown<cr>", mode = "t" },
      { "<C-k>", "<C-\\><C-n><cmd>TmuxNavigateUp<cr>", mode = "t" },
      { "<C-l>", "<C-\\><C-n><cmd>TmuxNavigateRight<cr>", mode = "t" },
    },
    init = function()
      vim.g.tmux_navigator_no_mappings = 1
    end,
  },
}
