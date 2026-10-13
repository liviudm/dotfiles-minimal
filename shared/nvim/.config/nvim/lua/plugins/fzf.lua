return {
  {
    "ibhagwan/fzf-lua",
    cmd = "FzfLua",
    keys = {
      { "<leader>ff", function() require("fzf-lua").files() end, desc = "Files" },
      { "<leader>fg", function() require("fzf-lua").live_grep() end, desc = "Live grep" },
      { "<leader>fw", function() require("fzf-lua").grep_cword() end, desc = "Grep word" },
      { "<leader>fb", function() require("fzf-lua").buffers() end, desc = "Buffers" },
      { "<leader>fh", function() require("fzf-lua").helptags() end, desc = "Help tags" },
      { "<leader>fr", function() require("fzf-lua").oldfiles() end, desc = "Recent files" },
      { "<leader>f/", function() require("fzf-lua").lgrep_curbuf() end, desc = "Buffer lines" },
      { "<leader>fk", function() require("fzf-lua").keymaps() end, desc = "Keymaps" },
    },
    opts = {},
  },
}
