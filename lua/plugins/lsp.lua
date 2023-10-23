return {
  {
    "j-hui/fidget.nvim",
    branch = "legacy",
    event = "LspAttach",
    opts = {},
  },

  {
    "neovim/nvim-lspconfig",
    event = { "BufReadPre", "BufNewFile" },
    dependencies = {
      "williamboman/mason.nvim",
      "williamboman/mason-lspconfig.nvim",
      { "folke/neodev.nvim" },
      { "b0o/SchemaStore.nvim", version = false },
    },
    config = function()
      local icons = require("util").icons

      for name, icon in pairs(icons.diagnostics) do
        name = "DiagnosticSign" .. name
        vim.fn.sign_define(name, { text = icon, texthl = name, numhl = "" })
      end
      vim.diagnostic.config({
        underline = true,
        update_in_insert = false,
        virtual_text = { spacing = 4, source = "if_many", prefix = "●" },
        severity_sort = true,
      })

      require("mason").setup()
      require("mason-lspconfig").setup({
        ensure_installed = {
          "lua_ls",
          "rust_analyzer",
          "tsserver",
          "jsonls",
          "yamlls",
        },
      })

      local lspconfig = require("lspconfig")
      local capabilities = require("cmp_nvim_lsp").default_capabilities()
      local flags = { debounce_text_changes = 500 }

      lspconfig.sourcekit.setup({
        capabilities = capabilities,
        flags = flags,
      })

      require("mason-lspconfig").setup_handlers({
        function(server_name)
          lspconfig[server_name].setup({
            capabilities = capabilities,
            flags = flags,
          })
        end,
        rust_analyzer = function()
          lspconfig.rust_analyzer.setup({
            capabilities = capabilities,
            flags = flags,
            settings = {
              ["rust-analyzer"] = {
                diagnostics = {
                  disabled = { "inactive-code" },
                },
              },
            },
          })
        end,
        lua_ls = function()
          require("neodev").setup()
          lspconfig.lua_ls.setup({
            capabilities = capabilities,
            flags = flags,
            settings = {
              Lua = {
                workspace = { checkThirdParty = false },
                completion = { callSnippet = "Replace" },
                telemetry = { enable = false },
                format = { enable = false },
              },
            },
          })
        end,
        jsonls = function()
          lspconfig.jsonls.setup({
            capabilities = capabilities,
            flags = flags,
            settings = {
              json = {
                format = { enable = true },
                validate = { enable = true },
                schemas = require("schemastore").json.schemas(),
              },
            },
          })
        end,
        yamlls = function()
          lspconfig.yamlls.setup({
            capabilities = capabilities,
            flags = flags,
            settings = {
              yaml = {
                hover = true,
                completion = true,
                validate = true,
                schemas = require("schemastore").yaml.schemas(),
              },
            },
          })
        end,
        tsserver = function()
          lspconfig.tsserver.setup({
            capabilities = capabilities,
            flags = flags,
            init_options = {
              preferences = {
                disableSuggestions = true,
              },
            },
            settings = {
              completions = {
                completeFunctionCalls = true,
              },
            },
          })
        end,
      })
    end,
  },

  {
    "jose-elias-alvarez/null-ls.nvim",
    dependencies = { "mason.nvim" },
    event = { "BufReadPre", "BufNewFile" },
    opts = function()
      local nls = require("null-ls")
      return {
        sources = {
          nls.builtins.formatting.prettierd,
          nls.builtins.formatting.stylua,
          nls.builtins.formatting.eslint_d,

          nls.builtins.diagnostics.eslint_d,

          nls.builtins.code_actions.eslint_d,
        },
      }
    end,
  },
}
