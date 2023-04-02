local util = require("util")

local map = util.map
local icons = util.icons

return {
  {
    "neovim/nvim-lspconfig",
    event = { "BufReadPre", "BufNewFile" },
    dependencies = {
      "williamboman/mason.nvim",
      "williamboman/mason-lspconfig.nvim",
      { "j-hui/fidget.nvim", opts = {} },
      { "folke/neodev.nvim", opts = { experimental = { pathStrict = true } } },
      { "b0o/SchemaStore.nvim", version = false },
    },
    opts = {
      -- options for vim.diagnostic.config()
      diagnostics = {
        underline = true,
        update_in_insert = false,
        virtual_text = { spacing = 4, prefix = "●" },
        severity_sort = true,
      },
      -- options for vim.lsp.buf.format
      format = {
        formatting_options = nil,
        timeout_ms = nil,
      },
      servers = {
        lua_ls = {
          Lua = {
            workspace = { checkThirdParty = false },
            completion = { callSnippet = "Replace" },
            telemetry = { enable = false },
          },
        },
        tsserver = {
          settings = {
            completions = {
              completeFunctionCalls = true,
            },
          },
        },
        jsonls = {
          -- lazy-load schemastore when needed
          on_new_config = function(new_config)
            new_config.settings.json.schemas = new_config.settings.json.schemas or {}
            vim.list_extend(new_config.settings.json.schemas, require("schemastore").json.schemas())
          end,
          settings = {
            json = {
              format = {
                enable = true,
              },
              validate = { enable = true },
            },
          },
        },
      },
      setup = {
        -- example to setup with typescript.nvim
        -- tsserver = function(_, opts)
        --   require("typescript").setup({ server = opts })
        --   return true
        -- end,
        -- Specify * to use this function as a fallback for any server
        -- ["*"] = function(server, opts) end,
      },
    },
    config = function(_, opts)
      vim.api.nvim_create_autocmd("LspAttach", {
        callback = function(args)
          local buffer = args.buf

          local nmap = function(keys, func, desc) map("n", keys, func, { buffer = buffer, desc = desc }) end

          nmap("]d", vim.diagnostic.goto_next, "Next diagnostic")
          nmap("[d", vim.diagnostic.goto_prev, "Previous diagnostic")
          nmap("ge", vim.diagnostic.open_float)
          nmap("gq", vim.diagnostic.setloclist)

          nmap("gd", vim.lsp.buf.definition, "Goto Definition")
          nmap("gI", vim.lsp.buf.implementation, "Goto Implementation")

          nmap("K", vim.lsp.buf.hover, "Hover Documentation")

          nmap("<leader>lh", vim.lsp.buf.signature_help, "Signature Documentation")
          nmap("<leader>la", vim.lsp.buf.code_action, "Code action")
          nmap("<leader>lr", vim.lsp.buf.rename, "Rename")

          -- Formatting
          local client = vim.lsp.get_client_by_id(args.data.client_id)

          if
            client.config
            and client.config.capabilities
            and client.config.capabilities.documentFormattingProvider == false
          then
            return
          end

          nmap("<leader>lf", vim.lsp.buf.format, "Format buffer")

          if client.supports_method("textDocument/formatting") then
            vim.api.nvim_create_autocmd("BufWritePre", {
              group = vim.api.nvim_create_augroup("LspFormat." .. buffer, {}),
              buffer = buffer,
              callback = function()
                local ft = vim.bo[buffer].filetype
                local have_nls = #require("null-ls.sources").get_available(ft, "NULL_LS_FORMATTING") > 0

                vim.lsp.buf.format(vim.tbl_deep_extend("force", {
                  bufnr = buffer,
                  filter = function(cl)
                    if have_nls then return cl.name == "null-ls" end
                    return cl.name ~= "null-ls"
                  end,
                }, opts.format))
              end,
            })
          end
        end,
      })

      for name, icon in pairs(icons.diagnostics) do
        name = "DiagnosticSign" .. name
        vim.fn.sign_define(name, { text = icon, texthl = name, numhl = "" })
      end
      vim.diagnostic.config(opts.diagnostics)

      local capabilities = vim.lsp.protocol.make_client_capabilities()
      capabilities = require("cmp_nvim_lsp").default_capabilities(capabilities)

      local function setup(server)
        local server_opts = vim.tbl_deep_extend("force", {
          capabilities = vim.deepcopy(capabilities),
        }, opts.servers[server] or {})

        if opts.setup[server] then
          if opts.setup[server](server, server_opts) then return end
        elseif opts.setup["*"] then
          if opts.setup["*"](server, server_opts) then return end
        end
        require("lspconfig")[server].setup(server_opts)
      end

      local mlsp = require("mason-lspconfig")
      local available = mlsp.get_available_servers()

      local ensure_installed = {} ---@type string[]
      for server, server_opts in pairs(opts.servers) do
        if server_opts then
          server_opts = server_opts == true and {} or server_opts
          -- run manual setup if mason=false or if this is a server that cannot be installed with mason-lspconfig
          if server_opts.mason == false or not vim.tbl_contains(available, server) then
            setup(server)
          else
            ensure_installed[#ensure_installed + 1] = server
          end
        end
      end

      require("mason-lspconfig").setup({ ensure_installed = ensure_installed })
      require("mason-lspconfig").setup_handlers({ setup })
    end,
  },

  {
    "williamboman/mason.nvim",
    cmd = "Mason",
    keys = { { "<leader>cm", "<cmd>Mason<cr>", desc = "Mason" } },
    opts = {
      ensure_installed = {
        "prettierd",
        "rust-analyzer",
        "stylua",
        "shellcheck",
        "typescript-language-server",
      },
    },
    ---@param opts MasonSettings | {ensure_installed: string[]}
    config = function(_, opts)
      require("mason").setup(opts)
      local mr = require("mason-registry")
      for _, tool in ipairs(opts.ensure_installed) do
        local p = mr.get_package(tool)
        if not p:is_installed() then p:install() end
      end
    end,
  },

  {
    "jose-elias-alvarez/null-ls.nvim",
    event = { "BufReadPre", "BufNewFile" },
    dependencies = { "mason.nvim" },
    opts = function()
      local nls = require("null-ls")
      return {
        sources = {
          nls.builtins.formatting.prettierd,
          nls.builtins.formatting.stylua,
        },
      }
    end,
  },
}
