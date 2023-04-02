local M = {}

M.map = function(mode, lhs, rhs, opts)
  opts = opts or {}
  opts.silent = opts.silent ~= false

  vim.keymap.set(mode, lhs, rhs, opts)
end

M.icons = {
  diagnostics = {
    Error = "● ",
    Warn = "● ",
    Hint = "● ",
    Info = "● ",

    error = "● ",
    warn = "● ",
    hint = "● ",
    info = "● ",

    -- Error = " ",
    -- Warn = " ",
    -- Hint = " ",
    -- Info = " ",
  },
  git = {
    added = "● ",
    modified = "● ",
    removed = "● ",

    -- added = " ",
    -- modified = " ",
    -- removed = " ",
  },
  kinds = {
    Array = " ",
    Boolean = " ",
    Class = " ",
    Color = " ",
    Constant = " ",
    Constructor = " ",
    Copilot = " ",
    Enum = " ",
    EnumMember = " ",
    Event = " ",
    Field = " ",
    File = " ",
    Folder = " ",
    Function = " ",
    Interface = " ",
    Key = " ",
    Keyword = " ",
    Method = " ",
    Module = " ",
    Namespace = " ",
    Null = "ﳠ ",
    Number = " ",
    Object = " ",
    Operator = " ",
    Package = " ",
    Property = " ",
    Reference = " ",
    Snippet = " ",
    String = " ",
    Struct = " ",
    Text = " ",
    TypeParameter = " ",
    Unit = " ",
    Value = " ",
    Variable = " ",
  },
}

return M
