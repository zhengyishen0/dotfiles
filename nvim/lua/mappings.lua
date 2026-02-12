require "nvchad.mappings"

local map = vim.keymap.set

-- Override NvChad C-h/j/k/l with tmux-aware navigation
map({ "n", "t" }, "<C-h>", "<cmd>TmuxNavigateLeft<CR>", { desc = "Navigate left" })
map({ "n", "t" }, "<C-j>", "<cmd>TmuxNavigateDown<CR>", { desc = "Navigate down" })
map({ "n", "t" }, "<C-k>", "<cmd>TmuxNavigateUp<CR>", { desc = "Navigate up" })
map({ "n", "t" }, "<C-l>", "<cmd>TmuxNavigateRight<CR>", { desc = "Navigate right" })

map("n", ";", ":", { desc = "CMD enter command mode" })
map("i", "jk", "<ESC>")

map({ "n", "i" }, "<leader>s", "<cmd>w<CR>", { desc = "Save file" })
map("n", "<leader><Tab>", "<C-w>w", { desc = "Cycle splits" })
map("n", "<leader>q", "<cmd>qa<CR>", { desc = "Quit all" })

-- =============================================================================
-- macOS-style navigation
-- =============================================================================

-- Word navigation (Opt+arrow)
map({ "n", "v" }, "<M-Left>", "b", { desc = "Word back" })
map({ "n", "v" }, "<M-Right>", "w", { desc = "Word forward" })
map("i", "<M-Left>", "<C-o>b", { desc = "Word back" })
map("i", "<M-Right>", "<C-o>w", { desc = "Word forward" })
map("c", "<M-Left>", "<S-Left>", { desc = "Word back" })
map("c", "<M-Right>", "<S-Right>", { desc = "Word forward" })
map("t", "<M-Left>", "<Esc>b", { desc = "Word back" })
map("t", "<M-Right>", "<Esc>f", { desc = "Word forward" })

-- Line navigation (Cmd+arrow via Ghostty Home/End remap)
map({ "n", "v" }, "<Home>", "0", { desc = "Line start" })
map({ "n", "v" }, "<End>", "$", { desc = "Line end" })
map("i", "<Home>", "<Home>", { desc = "Line start" })
map("i", "<End>", "<End>", { desc = "Line end" })

-- Document navigation (Cmd+Up/Down via Ghostty Ctrl+Home/End remap)
map({ "n", "v" }, "<C-Home>", "gg", { desc = "Top of file" })
map({ "n", "v" }, "<C-End>", "G", { desc = "Bottom of file" })
map("i", "<C-Home>", "<C-o>gg", { desc = "Top of file" })
map("i", "<C-End>", "<C-o>G", { desc = "Bottom of file" })

-- Shift+arrow = visual select
map("n", "<S-Left>", "v<Left>", { desc = "Select left" })
map("n", "<S-Right>", "v<Right>", { desc = "Select right" })
map("n", "<S-Up>", "v<Up>", { desc = "Select up" })
map("n", "<S-Down>", "v<Down>", { desc = "Select down" })
map("v", "<S-Left>", "<Left>", { desc = "Extend left" })
map("v", "<S-Right>", "<Right>", { desc = "Extend right" })
map("v", "<S-Up>", "<Up>", { desc = "Extend up" })
map("v", "<S-Down>", "<Down>", { desc = "Extend down" })

-- Shift+Opt+arrow = select by word
map("n", "<M-S-Left>", "vb", { desc = "Select word back" })
map("n", "<M-S-Right>", "vw", { desc = "Select word forward" })
map("v", "<M-S-Left>", "b", { desc = "Extend word back" })
map("v", "<M-S-Right>", "w", { desc = "Extend word forward" })

-- Shift+Cmd+arrow = select to line start/end (via Ghostty Shift+Home/End)
map("n", "<S-Home>", "v0", { desc = "Select to line start" })
map("n", "<S-End>", "v$", { desc = "Select to line end" })
map("v", "<S-Home>", "0", { desc = "Extend to line start" })
map("v", "<S-End>", "$", { desc = "Extend to line end" })

-- Shift+Cmd+Up/Down = select to top/bottom
map("n", "<C-S-Home>", "vgg", { desc = "Select to top" })
map("n", "<C-S-End>", "vG", { desc = "Select to bottom" })
map("v", "<C-S-Home>", "gg", { desc = "Extend to top" })
map("v", "<C-S-End>", "G", { desc = "Extend to bottom" })

-- Enter to copy in visual mode
map("v", "<CR>", "y", { desc = "Copy selection" })

-- Auto-copy to clipboard on mouse select (like tmux)
map("v", "<LeftRelease>", '"+y', { desc = "Auto-copy on mouse select" })

-- =============================================================================
-- Bottom terminal lazyjj (simple toggle)
-- =============================================================================

_G.lazyjj_state = { buf = nil, win = nil }
local lazyjj_state = _G.lazyjj_state

local function lazyjj_cleanup()
  if lazyjj_state.win and vim.api.nvim_win_is_valid(lazyjj_state.win) then
    vim.api.nvim_win_close(lazyjj_state.win, true)
  end
  if lazyjj_state.buf and vim.api.nvim_buf_is_valid(lazyjj_state.buf) then
    vim.api.nvim_buf_delete(lazyjj_state.buf, { force = true })
  end
  lazyjj_state.win = nil
  lazyjj_state.buf = nil
end

_G.toggle_lazyjj = function() end -- forward declare
local function toggle_lazyjj()
  -- If open, close it
  if lazyjj_state.win and vim.api.nvim_win_is_valid(lazyjj_state.win) then
    lazyjj_cleanup()
    return
  end

  -- Always start fresh so lazyjj picks up latest repo state
  lazyjj_cleanup()
  vim.cmd("botright new")
  vim.cmd("resize 20")
  lazyjj_state.win = vim.api.nvim_get_current_win()
  lazyjj_state.buf = vim.api.nvim_get_current_buf()
  vim.bo[lazyjj_state.buf].buflisted = false

  vim.fn.termopen("lazyjj", {
    on_exit = function()
      vim.schedule(lazyjj_cleanup)
    end,
  })
  vim.cmd("startinsert")

  -- Auto-enter insert mode when clicking into the lazyjj buffer
  vim.api.nvim_create_autocmd("BufEnter", {
    buffer = lazyjj_state.buf,
    callback = function()
      if lazyjj_state.buf and vim.api.nvim_buf_is_valid(lazyjj_state.buf) then
        vim.cmd("startinsert")
      end
    end,
  })

  -- Ctrl+k from lazyjj goes to editor (first non-special window)
  vim.keymap.set("t", "<C-k>", function()
    for _, win in ipairs(vim.api.nvim_list_wins()) do
      local buf = vim.api.nvim_win_get_buf(win)
      local ft = vim.bo[buf].filetype
      if ft ~= "Outline" and ft ~= "NvimTree" and ft ~= "" then
        vim.api.nvim_set_current_win(win)
        return
      end
    end
    vim.cmd("wincmd k")
  end, { buffer = lazyjj_state.buf, desc = "Jump to editor" })
end

_G.toggle_lazyjj = toggle_lazyjj
map({ "n", "t" }, "<leader>j", toggle_lazyjj, { desc = "Toggle lazyjj (bottom)" })

-- map({ "n", "i", "v" }, "<C-s>", "<cmd> w <cr>")

-- =============================================================================
-- Disable dangerous single-letter commands (use alternatives below)
-- =============================================================================
local nop = "<Nop>"
map("n", "x", nop, { desc = "Disabled: use dl" })
map("n", "X", nop, { desc = "Disabled: use dh" })
map("n", "r", nop, { desc = "Disabled: use cl<char><Esc>" })
map("n", "R", nop, { desc = "Disabled: use insert mode" })
map("n", "D", nop, { desc = "Disabled: use d$" })
map("n", "C", nop, { desc = "Disabled: use c$" })
map("n", "J", nop, { desc = "Disabled: use :join" })
map("n", "d", nop, { desc = "Disabled: use visual select + delete" })
map("n", "c", nop, { desc = "Disabled: use visual select + delete + type" })
-- s/S already remapped by flash.nvim

-- =============================================================================
-- Alternatives cheatsheet (safe editing):
-- =============================================================================
-- x  (del char)      → delete key in insert mode
-- X  (del char back) → backspace in insert mode
-- d  (del + motion)  → visual select + delete key
-- c  (change)        → visual select + delete + type
-- s  (subst char)    → cl       (now: flash jump)
-- S  (subst line)    → cc       (now: flash treesitter)
-- r  (replace char)  → cl<char><Esc>  or  visual + r
-- R  (replace mode)  → i (insert) or visual select + paste
-- D  (del to EOL)    → d$
-- C  (change to EOL) → c$
-- J  (join lines)    → :join<CR>
-- ~  (toggle case)   → kept enabled
