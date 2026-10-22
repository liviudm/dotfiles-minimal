return {
  {
    "neovim/nvim-lspconfig",
    event = { "BufReadPre", "BufNewFile" },
    dependencies = {
      "williamboman/mason.nvim",
      "williamboman/mason-lspconfig.nvim",
      "WhoIsSethDaniel/mason-tool-installer.nvim",
      "b0o/schemastore.nvim",
      "saghen/blink.cmp",
    },
    config = function()
      require("mason").setup()
      require("mason-lspconfig").setup({ automatic_installation = false, ensure_installed = {} })
      require("mason-tool-installer").setup({
        ensure_installed = {
          "pyright",
          "ruff",
          "bash-language-server",
          "lua-language-server",
          "json-lsp",
          "yaml-language-server",
          "helm-ls",
          "marksman",
          "taplo",
        },
        run_on_start = true,
        start_delay = 1000,
      })

      local capabilities = require("blink.cmp").get_lsp_capabilities()
      vim.lsp.config("*", { capabilities = capabilities })

      vim.lsp.config("pyright", {
        settings = { python = { analysis = { typeCheckingMode = "standard" } } },
      })

      vim.lsp.config("bashls", { filetypes = { "sh", "bash" } })

      vim.lsp.config("lua_ls", {
        settings = {
          Lua = {
            workspace = { checkThirdParty = false },
            diagnostics = { globals = { "vim" } },
            telemetry = { enable = false },
          },
        },
      })

      vim.lsp.config("jsonls", {
        settings = {
          json = {
            schemas = require("schemastore").json.schemas(),
            validate = { enable = true },
          },
        },
      })

      vim.lsp.config("helm_ls", {
        settings = {
          ["helm-ls"] = { yamlls = { path = "yaml-language-server" } },
        },
      })

      vim.lsp.enable({
        "pyright", "ruff", "bashls", "lua_ls", "jsonls", "marksman", "taplo", "helm_ls",
      })

      vim.api.nvim_create_autocmd("LspAttach", {
        group = vim.api.nvim_create_augroup("dotfiles-lsp", { clear = true }),
        callback = function(args)
          local buf = args.buf
          local map = function(mode, lhs, rhs, desc)
            vim.keymap.set(mode, lhs, rhs, { buffer = buf, silent = true, desc = desc })
          end
          map("n", "gd", vim.lsp.buf.definition, "Definition")
          map("n", "gI", vim.lsp.buf.implementation, "Implementation")
          map("n", "gy", vim.lsp.buf.type_definition, "Type definition")
          map("n", "K", vim.lsp.buf.hover, "Hover")
          map("i", "<C-k>", vim.lsp.buf.signature_help, "Signature")
          map({ "n", "v" }, "<leader>la", vim.lsp.buf.code_action, "Code action")
          map("n", "<leader>lr", vim.lsp.buf.rename, "Rename")
          map("n", "<leader>ls", function() require("fzf-lua").lsp_document_symbols() end, "Doc symbols")
          map("n", "<leader>lS", function() require("fzf-lua").lsp_live_workspace_symbols() end, "Workspace symbols")
          map("n", "gr", function() require("fzf-lua").lsp_references() end, "References")

          local client = vim.lsp.get_client_by_id(args.data.client_id)
          if client and client.name == "ruff" then
            client.server_capabilities.hoverProvider = false
          end
        end,
      })

      vim.diagnostic.config({
        virtual_text = { spacing = 2, prefix = "●" },
        severity_sort = true,
        float = { border = "rounded" },
      })
    end,
  },
  { "williamboman/mason.nvim", cmd = "Mason", build = ":MasonUpdate", opts = {} },
  { "williamboman/mason-lspconfig.nvim" },
  { "WhoIsSethDaniel/mason-tool-installer.nvim" },
  { "b0o/schemastore.nvim", lazy = true },
}
