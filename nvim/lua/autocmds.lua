require "nvchad.autocmds"

-- Hide special buffers from tabline (Outline, NvimTree, split artifacts, etc.)
vim.api.nvim_create_autocmd("BufEnter", {
  callback = function()
    local ft = vim.bo.filetype
    local bt = vim.bo.buftype
    local name = vim.api.nvim_buf_get_name(0)
    -- Hide: Outline, NvimTree, nofile buftype, or "vs" split artifact
    if ft == "Outline" or ft == "NvimTree" or bt == "nofile" or name:match("/vs$") or name:match("^vs$") then
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
