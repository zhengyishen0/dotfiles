require "nvchad.autocmds"

-- Hide special buffers from tabline + auto-enter terminal mode
vim.api.nvim_create_autocmd({ "BufEnter", "WinEnter" }, {
  callback = function()
    local ft = vim.bo.filetype
    local bt = vim.bo.buftype
    local name = vim.api.nvim_buf_get_name(0)
    -- Hide: Outline, NvimTree, terminals, nofile, or "vs" split artifact
    if ft == "Outline" or ft == "NvimTree" or bt == "nofile" or bt == "terminal" or name:match("/vs$") then
      vim.bo.buflisted = false
    end
    -- Auto-enter insert mode for terminals
    if bt == "terminal" then
      vim.cmd("startinsert")
    end
  end,
})
