return {
  {
    "echasnovski/mini.comment",
    opts = {
      hooks = {
        pre = function() require("ts_context_commentstring.internal").update_commentstring({}) end,
      },
    },
    config = function(_, opts) require("mini.comment").setup(opts) end,
  },
  {
    "echasnovski/mini.pairs",
    opts = {},
    config = function(_, opts) require("mini.pairs").setup(opts) end,
  },
  {
    "echasnovski/mini.surround",
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
    config = function(_, opts) require("mini.surround").setup(opts) end,
  },

  {
    "RRethy/vim-illuminate",
    event = { "BufReadPost", "BufNewFile" },
    opts = {},
    config = function(_, opts)
      require("illuminate").configure(opts)
      local map = require("util").map

      map("n", "]r", function() require("illuminate").goto_next_reference(false) end, { desc = "Next Reference" })
      map("n", "[r", function() require("illuminate").goto_prev_reference(false) end, { desc = "Prev Reference" })
    end,
  },
}
