return {
  {
    "echasnovski/mini.comment",
    version = false,
    event = { "BufReadPost", "BufNewFile" },
    opts = {
      options = {
        custom_commentstring = function()
          return vim.bo.commentstring
        end,
      },
      hooks = {
        pre = function()
          require("ts_context_commentstring.internal").update_commentstring()
        end,
      },
    },
  },
  {
    "echasnovski/mini.surround",
    version = false,
    event = { "BufReadPost", "BufNewFile" },
    opts = {
      mappings = {
        add = "gza", -- Add surrounding in Normal and Visual modes
        delete = "gzd", -- Delete surrounding
        find = "gzf", -- Find surrounding (to the right)
        find_left = "gzF", -- Find surrounding (to the left)
        highlight = "gzh", -- Highlight surrounding
        replace = "gzr", -- Replace surrounding
        update_n_lines = "gzn", -- Update `n_lines`
      },
    },
  },

  {
    "RRethy/vim-illuminate",
    event = { "BufReadPost", "BufNewFile" },
    opts = {},
    config = function(_, opts)
      require("illuminate").configure(opts)
      local map = require("util").map

      map("n", "]r", function()
        require("illuminate").goto_next_reference(false)
      end, { desc = "Next Reference" })
      map("n", "[r", function()
        require("illuminate").goto_prev_reference(false)
      end, { desc = "Prev Reference" })
    end,
  },
}
