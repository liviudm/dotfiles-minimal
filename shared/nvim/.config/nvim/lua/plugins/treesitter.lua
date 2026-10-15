local parsers = {
  "bash", "c", "diff", "git_config", "gitcommit", "gitignore",
  "go", "json", "lua", "luadoc", "markdown", "markdown_inline",
  "python", "query", "regex", "toml", "vim", "vimdoc", "yaml",
}

return {
  {
    "nvim-treesitter/nvim-treesitter",
    branch = "main",
    lazy = false,
    build = ":TSUpdate",
    config = function()
      -- JSONC is a filetype, not a separately supported parser.
      vim.treesitter.language.register("json", "jsonc")
      require("nvim-treesitter").install(parsers)
      vim.api.nvim_create_autocmd("FileType", {
        callback = function(ev)
          pcall(vim.treesitter.start, ev.buf)
          pcall(function()
            vim.bo[ev.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
          end)
        end,
      })
    end,
  },
  {
    "nvim-treesitter/nvim-treesitter-textobjects",
    branch = "main",
    dependencies = { "nvim-treesitter/nvim-treesitter" },
    config = function()
      require("nvim-treesitter-textobjects").setup({ select = { lookahead = true } })
      local sel = require("nvim-treesitter-textobjects.select")
      local move = require("nvim-treesitter-textobjects.move")
      local selects = {
        af = "@function.outer", ["if"] = "@function.inner",
        ac = "@class.outer",    ic = "@class.inner",
        aa = "@parameter.outer", ia = "@parameter.inner",
      }
      for lhs, q in pairs(selects) do
        vim.keymap.set({ "x", "o" }, lhs, function() sel.select_textobject(q, "textobjects") end)
      end
      for lhs, q in pairs({ ["]f"] = "@function.outer", ["]c"] = "@class.outer" }) do
        vim.keymap.set("n", lhs, function() move.goto_next_start(q, "textobjects") end)
      end
      for lhs, q in pairs({ ["[f"] = "@function.outer", ["[c"] = "@class.outer" }) do
        vim.keymap.set("n", lhs, function() move.goto_previous_start(q, "textobjects") end)
      end
    end,
  },
}
