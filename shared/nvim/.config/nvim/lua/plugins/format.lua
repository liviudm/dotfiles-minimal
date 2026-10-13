return {
  {
    "stevearc/conform.nvim",
    event = { "BufWritePre" },
    cmd = { "ConformInfo" },
    keys = {
      {
        "<leader>lf",
        function() require("conform").format({ async = true, lsp_format = "never" }) end,
        mode = { "n", "v" },
        desc = "Format buffer/range",
      },
      {
        "<leader>uf",
        function()
          vim.g.autoformat = not vim.g.autoformat
          vim.notify("Format on save: " .. (vim.g.autoformat and "on" or "off"))
        end,
        desc = "Toggle format on save",
      },
    },
    opts = {
      formatters_by_ft = {
        python = { "ruff_fix", "ruff_format" },
        lua = { "stylua" },
        sh = { "shfmt" },
        bash = { "shfmt" },
        json = { "prettierd" },
        jsonc = { "prettierd" },
        yaml = { "prettierd" },
        markdown = { "prettierd" },
        toml = { "taplo" },
      },
      format_on_save = function(bufnr)
        if not vim.g.autoformat then return end
        if vim.b[bufnr].autoformat == false then return end
        return { timeout_ms = 1000, lsp_format = "never" }
      end,
    },
  },
}
