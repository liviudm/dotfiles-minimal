return {
  {
    "nvim-neo-tree/neo-tree.nvim",
    cmd = "Neotree",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "MunifTanjim/nui.nvim",
      "nvim-tree/nvim-web-devicons",
    },
    keys = {
      { "<leader>e", "<cmd>Neotree toggle<cr>", desc = "Explorer toggle" },
      { "<leader>E", "<cmd>Neotree reveal<cr>", desc = "Explorer reveal" },
    },
    init = function()
      -- Required so `nvim <dir>` loads neo-tree instead of netrw under lazy-loading.
      vim.api.nvim_create_autocmd("BufEnter", {
        group = vim.api.nvim_create_augroup("neo_tree_start_dir", { clear = true }),
        once = true,
        callback = function()
          if package.loaded["neo-tree"] then return end
          local stats = vim.uv.fs_stat(vim.fn.argv(0))
          if stats and stats.type == "directory" then
            require("neo-tree")
          end
        end,
      })
    end,
    opts = {
      close_if_last_window = true,
      window = {
        position = "left",
        width = 30,
        mappings = {
          -- Buffer-local tree bindings must preserve cross-window navigation.
          ["<C-h>"] = function() vim.cmd("TmuxNavigateLeft") end,
          ["<C-j>"] = function() vim.cmd("TmuxNavigateDown") end,
          ["<C-k>"] = function() vim.cmd("TmuxNavigateUp") end,
          ["<C-l>"] = function() vim.cmd("TmuxNavigateRight") end,
          ["l"] = "open",
          ["h"] = "close_node",
        },
      },
      filesystem = {
        hijack_netrw_behavior = "open_default",
        follow_current_file = { enabled = true },
        filtered_items = {
          visible = true,
          hide_dotfiles = false,
          hide_gitignored = false,
        },
        commands = {
          delete = function(state)
            local inputs = require("neo-tree.ui.inputs")
            local path = state.tree:get_node().path
            inputs.confirm("Trash " .. path .. "?", function(confirmed)
              if not confirmed then return end
              vim.fn.system({ "trash", path })
              require("neo-tree.sources.manager").refresh(state.name)
            end)
          end,
        },
      },
    },
  },
}
