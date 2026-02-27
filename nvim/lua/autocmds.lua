require "nvchad.autocmds"

-- Hide special buffers from tabline (aerial, NvimTree, split artifacts)
vim.api.nvim_create_autocmd("BufEnter", {
  callback = function()
    local ft = vim.bo.filetype
    local bt = vim.bo.buftype
    local name = vim.api.nvim_buf_get_name(0)
    -- Hide: aerial, NvimTree, nofile buftype, or "vs" split artifact
    if ft == "aerial" or ft == "NvimTree" or bt == "nofile" or name:match("/vs$") then
      vim.bo.buflisted = false
    end
  end,
})

-- Auto-enter terminal mode when focusing a terminal buffer
vim.api.nvim_create_autocmd({ "BufEnter", "WinEnter" }, {
  pattern = "term://*",
  callback = function()
    if vim.bo.buftype == "terminal" then
      vim.cmd("startinsert")
    end
  end,
})

-- Auto-highlight word under cursor (like * but automatic)
local hl_group = vim.api.nvim_create_augroup("WordHighlight", {})
vim.api.nvim_create_autocmd("CursorMoved", {
  group = hl_group,
  callback = function()
    if vim.w.word_hl_id then
      pcall(vim.fn.matchdelete, vim.w.word_hl_id)
      vim.w.word_hl_id = nil
    end
    if vim.bo.buftype ~= "" then return end
    local word = vim.fn.expand("<cword>")
    if word == "" or #word < 2 then return end
    local escaped = vim.fn.escape(word, "\\/.*$^~[]")
    vim.w.word_hl_id = vim.fn.matchadd("CursorColumn", "\\V\\<" .. escaped .. "\\>", -1)
  end,
})
