local util = require("util")

local icons = util.icons

-- local servers = {}

return {
  {
    "stevearc/dressing.nvim",
    lazy = true,
    init = function()
      ---@diagnostic disable-next-line: duplicate-set-field
      vim.ui.select = function(...)
        require("lazy").load({ plugins = { "dressing.nvim" } })
        return vim.ui.select(...)
      end
      ---@diagnostic disable-next-line: duplicate-set-field
      vim.ui.input = function(...)
        require("lazy").load({ plugins = { "dressing.nvim" } })
        return vim.ui.input(...)
      end
    end,
  },

  {
    "nvim-neo-tree/neo-tree.nvim",
    branch = "v3.x",
    cmd = "Neotree",
    keys = {
      {
        "<leader>e",
        function()
          require("neo-tree.command").execute({ toggle = true, dir = vim.loop.cwd() })
        end,
        desc = "Explorer toggle",
      },
    },
    deactivate = function()
      vim.cmd([[Neotree close]])
    end,
    opts = {
      auto_clean_after_session_restore = true,
      close_if_last_window = true,
      filesystem = {
        follow_current_file = {
          enabled = true,
        },
        use_libuv_file_watcher = true,
        window = {
          mappings = {
            ["o"] = "system_open",
          },
        },
        commands = {
          system_open = function(state)
            local node = state.tree:get_node()
            local path = node:get_id()
            vim.api.nvim_command("silent !open -g " .. path)
          end,
        },
        filtered_items = {
          visible = true,
          never_show = {
            ".DS_Store",
          },
        },
      },
      window = {
        width = 30,
        mappings = {
          ["<space>"] = "none",
        },
      },
      source_selector = {
        winbar = true,
      },
    },
  },

  {
    "hrsh7th/nvim-cmp",
    version = false,
    event = "InsertEnter",
    dependencies = {
      "hrsh7th/cmp-nvim-lsp",
      "hrsh7th/cmp-buffer",
      "hrsh7th/cmp-path",
      "hrsh7th/cmp-cmdline",
      "saadparwaiz1/cmp_luasnip",
    },
    opts = function()
      local cmp = require("cmp")
      local luasnip = require("luasnip")

      local has_words_before = function()
        local line, col = unpack(vim.api.nvim_win_get_cursor(0))
        return col ~= 0 and vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match("%s") == nil
      end

      ---@diagnostic disable-next-line: missing-fields
      cmp.setup.cmdline({ "/", "?" }, {
        mapping = cmp.mapping.preset.cmdline(),
        sources = {
          { name = "buffer" },
        },
      })

      return {
        completion = {
          completeopt = "menu,menuone,noinsert",
        },
        snippet = {
          expand = function(args)
            luasnip.lsp_expand(args.body)
          end,
        },
        window = {
          completion = cmp.config.window.bordered(),
          documentation = cmp.config.window.bordered(),
        },
        mapping = cmp.mapping.preset.insert({
          ["<C-n>"] = cmp.mapping.select_next_item({ behavior = cmp.SelectBehavior.Insert }),
          ["<C-p>"] = cmp.mapping.select_prev_item({ behavior = cmp.SelectBehavior.Insert }),
          ["<C-u>"] = cmp.mapping.scroll_docs(-4),
          ["<C-d>"] = cmp.mapping.scroll_docs(4),
          ["<C-Space>"] = cmp.mapping.complete(),
          ["<C-e>"] = cmp.mapping.abort(),
          ["<CR>"] = cmp.mapping.confirm({ select = true }),
          ["<Tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
              -- cmp.select_next_item()
              cmp.select_next_item({ behavior = cmp.SelectBehavior.Select })
            elseif luasnip.expand_or_jumpable() then
              luasnip.expand_or_jump()
            elseif has_words_before() then
              cmp.complete()
            else
              fallback()
            end
          end, { "i", "s" }),
          ["<S-Tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_prev_item({ behavior = cmp.SelectBehavior.Select })
            elseif luasnip.jumpable(-1) then
              luasnip.jump(-1)
            else
              fallback()
            end
          end, { "i", "s" }),
        }),
        sources = cmp.config.sources({
          { name = "nvim_lsp" },
          { name = "luasnip" },
          { name = "path" },
        }, {
          { name = "buffer", keyword_length = 3 },
        }),
        formatting = {
          format = function(_, item)
            local kinds = icons.kinds
            if kinds[item.kind] then
              item.kind = kinds[item.kind]
            end
            return item
          end,
        },
        experimental = {
          ghost_text = {
            hl_group = "LspCodeLens",
          },
        },
      }
    end,
  },

  {
    "nvim-lualine/lualine.nvim",
    opts = {
      options = {
        theme = "auto",
        globalstatus = true,
        disabled_filetypes = {
          statusline = { "lazy" },
          winbar = { "neo-tree" },
        },
        component_separators = "|",
        section_separators = "",
      },
      extensions = { "lazy", "neo-tree" },
      sections = {
        lualine_a = {
          {
            function()
              return " "
            end,
            padding = 0,
          },
        },
        lualine_b = { "branch" },
        lualine_c = {
          {
            "diff",
            symbols = {
              added = icons.git.added,
              modified = icons.git.modified,
              removed = icons.git.removed,
            },
          },
          {
            "filetype",
            icon_only = true,
            separator = "",
            padding = { left = 1, right = 0 },
          },
          { "filename", path = 0, symbols = { modified = "●", readonly = "", unnamed = "" } },
        },
        lualine_x = {
          { "searchcount" },
          -- {
          --   "lsp",
          --   fmt = function()
          --     local label = ""
          --     for k, lsp in pairs(servers) do
          --       print(vim.inspect(lsp))
          --       table.concat({
          --         label,
          --         lsp.title or "",
          --         lsp.message or "",
          --         lsp.percentage and "(" .. lsp.percentage .. "%)" or "",
          --       }, " ")
          --       servers[k] = nil
          --     end
          --     return label
          --     -- if not servers.registered then
          --     --   return ""
          --     -- end
          --     --
          --     -- local label = "Lsp: "
          --     --
          --     -- for server, finished in pairs(servers.status) do
          --     --   if server ~= "registered" then
          --     --     local icon = finished and "◉ " or "◌ "
          --     --     label = label .. icon .. server .. " "
          --     --   end
          --     -- end
          --     --
          --     -- return label
          --   end,
          -- },
          {
            "diagnostics",
            symbols = {
              error = icons.diagnostics.Error,
              warn = icons.diagnostics.Warn,
              info = icons.diagnostics.Info,
              hint = icons.diagnostics.Hint,
            },
          },
        },
        lualine_y = {
          { "progress", separator = "", padding = { left = 1, right = 1 } },
          { "location", padding = { left = 0, right = 1 } },
        },
        lualine_z = {
          {
            function()
              return " "
            end,
            padding = 0,
          },
        },
      },
    },
    config = function(_, opts)
      local lualine = require("lualine")
      lualine.setup(opts)

      --- Trigger an AstroNvim user event
      -- @param event string The event name to be appended to Astro
      -- local function evt(event)
      --   vim.schedule(function()
      --     vim.api.nvim_exec_autocmds("User", { pattern = "CustomEvent" .. event, modeline = false })
      --   end)
      -- end
      -- local function extend_tbl(default, o)
      --   o = o or {}
      --   return default and vim.tbl_deep_extend("force", default, o) or o
      -- end
      --
      -- local orig_handler = vim.lsp.handlers["$/progress"]
      -- vim.lsp.handlers["$/progress"] = function(_, msg, info)
      --   local progress, id = servers, ("%s.%s"):format(info.client_id, msg.token)
      --   progress[id] = progress[id] and extend_tbl(progress[id], msg.value) or msg.value
      --   lualine.refresh({
      --     scope = "lsp",
      --     place = { "statusline" },
      --   })
      --   -- print(vim.inspect(progress))
      --   -- if progress[id].kind == "end" then
      --   --   vim.defer_fn(function()
      --   --     progress[id] = nil
      --   --     evt "LspProgress"
      --   --   end, 100)
      --   -- end
      --   -- evt "LspProgress"
      --   orig_handler(_, msg, info)
      -- end

      -- local function handle_progress(_, msg, ctx)
      --   if msg.value.kind == "begin" or msg.value.kind == "end" then
      --     local client = vim.lsp.get_client_by_id(ctx.client_id)
      --     if client ~= nil then
      --       servers.registered = true
      --       servers.status[client.name] = msg.value.kind == "end"
      --
      --       lualine.refresh({
      --         scope = "lsp",
      --         place = { "statusline" },
      --       })
      --     end
      --   end
      -- end
      --
      -- if vim.lsp.handlers["$/progress"] then
      --   local old_handler = vim.lsp.handlers["$/progress"]
      --   ---@diagnostic disable-next-line: duplicate-set-field
      --   vim.lsp.handlers["$/progress"] = function(...)
      --     old_handler(...)
      --     handle_progress(...)
      --   end
      -- else
      --   vim.lsp.handlers["$/progress"] = handle_progress
      -- end
    end,
  },
}
