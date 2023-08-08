-- local group = vim.api.nvim_create_augroup("lsp_document_codelens", {})

-- -@param bufnr number
-- local function buf_autocmd_codelens(bufnr)
--   vim.api.nvim_create_autocmd({ "BufEnter", "InsertLeave", "BufWritePost", "CursorHold" }, {
--     buffer = bufnr,
--     group = group,
--     callback = function()
--       vim.lsp.codelens.refresh()
--     end,
--   })
-- end

local function lsp_format(bufnr, has_nls)
  vim.lsp.buf.format({
    bufnr = bufnr,
    async = false,
    formatting_options = nil,
    timeout_ms = nil,
    filter = function(cl)
      if has_nls then
        return cl.name == "null-ls"
      end
      return cl.name ~= "null-ls"
    end,
  })
end

vim.api.nvim_create_autocmd("LspAttach", {
  callback = function(args)
    local map = require("util").map
    local buffer = args.buf

    local nmap = function(keys, func, desc)
      map("n", keys, func, { buffer = buffer, desc = desc })
    end

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

    local client = vim.lsp.get_client_by_id(args.data.client_id)

    -- if client.supports_method("textDocument/codeLens") then
    --   buf_autocmd_codelens(buffer)
    --   vim.schedule(vim.lsp.codelens.refresh)
    -- end

    if client.supports_method("textDocument/formatting") then
      local ft = vim.bo[buffer].filetype
      local has_nls = #require("null-ls.sources").get_available(ft, "NULL_LS_FORMATTING") > 0

      nmap("<leader>lf", function()
        lsp_format(buffer, has_nls)
      end, "Format document")

      local augroup = vim.api.nvim_create_augroup("LspFormatting", {})
      vim.api.nvim_clear_autocmds({ group = augroup, buffer = buffer })
      vim.api.nvim_create_autocmd("BufWritePre", {
        group = augroup,
        buffer = buffer,
        callback = function()
          lsp_format(buffer, has_nls)
        end,
      })
    end
  end,
})
