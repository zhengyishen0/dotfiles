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

-- Shift+arrow = select (Select mode - typing replaces selection)
map("n", "<S-Left>", "gh<Left>", { desc = "Select left" })
map("n", "<S-Right>", "gh<Right>", { desc = "Select right" })
map("n", "<S-Up>", "gh<Up>", { desc = "Select up" })
map("n", "<S-Down>", "gh<Down>", { desc = "Select down" })
map("s", "<S-Left>", "<C-o><Left>", { desc = "Extend left" })
map("s", "<S-Right>", "<C-o><Right>", { desc = "Extend right" })
map("s", "<S-Up>", "<C-o><Up>", { desc = "Extend up" })
map("s", "<S-Down>", "<C-o><Down>", { desc = "Extend down" })

-- Shift+Opt+arrow = select by word (explicit CSI sequences from Ghostty)
map("n", "\x1b[1;4D", "vb<C-g>", { desc = "Select word back" })
map("n", "\x1b[1;4C", "vw<C-g>", { desc = "Select word forward" })
map("s", "<M-S-Left>", "<C-o>b", { desc = "Extend word back" })
map("s", "<M-S-Right>", "<C-o>w", { desc = "Extend word forward" })

-- Shift+Cmd+arrow = select to line start/end
map("n", "<S-Home>", "v0", { desc = "Select to line start" })
map("n", "<S-End>", "v$", { desc = "Select to line end" })
map("v", "<S-Home>", "0", { desc = "Extend to line start" })
map("v", "<S-End>", "$", { desc = "Extend to line end" })

-- Shift+Cmd+Up/Down = select to top/bottom
map("n", "<C-S-Home>", "vgg", { desc = "Select to top" })
map("n", "<C-S-End>", "vG", { desc = "Select to bottom" })
map("v", "<C-S-Home>", "gg", { desc = "Extend to top" })
map("v", "<C-S-End>", "G", { desc = "Extend to bottom" })

-- Enter to copy in select mode
map("s", "<CR>", "<C-o>y", { desc = "Copy selection" })

-- Auto-copy to clipboard on mouse select
map("s", "<LeftRelease>", '<C-o>"+y', { desc = "Auto-copy on mouse select" })

-- Cmd+Z/Shift+Z (undo/redo)
map("n", "<D-z>", "u", { desc = "Undo" })
map("i", "<D-z>", "<C-o>u", { desc = "Undo" })
map({ "n", "v" }, "<D-S-z>", "<C-r>", { desc = "Redo" })
map("i", "<D-S-z>", "<C-o><C-r>", { desc = "Redo" })

-- Cmd+S (save)
map({ "n", "i", "v", "s" }, "<D-s>", "<Cmd>w<CR>", { desc = "Save" })

-- Cmd+Q (quit all)
map({ "n", "i", "v", "s" }, "<D-q>", "<Cmd>qa<CR>", { desc = "Quit all" })

-- Cmd+E/O/J (NvimTree, Outline, lazyjj)
map({ "n", "i", "v", "s" }, "<D-e>", "<Cmd>NvimTreeFocus<CR>", { desc = "NvimTree" })
map({ "n", "i", "v", "s" }, "<D-o>", "<Cmd>Outline<CR>", { desc = "Outline" })
map({ "n", "i", "v", "s", "t" }, "<D-j>", function() _G.toggle_lazyjj() end, { desc = "Toggle lazyjj" })

-- Opt+Backspace = delete word backward
map("i", "<M-BS>", "<C-w>", { desc = "Delete word backward" })

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
-- Disable single-letter commands (macOS-style: click to type, select + type)
-- =============================================================================
local nop = "<Nop>"
-- Delete/change commands
map("n", "x", nop, { desc = "Disabled" })
map("n", "X", nop, { desc = "Disabled" })
map("n", "d", nop, { desc = "Disabled" })
map("n", "D", nop, { desc = "Disabled" })
map("n", "c", nop, { desc = "Disabled" })
map("n", "C", nop, { desc = "Disabled" })
map("n", "r", nop, { desc = "Disabled" })
map("n", "R", nop, { desc = "Disabled" })
map("n", "J", nop, { desc = "Disabled" })
-- s/S used by flash.nvim

-- Insert/append commands (use click or Enter instead)
map("n", "i", nop, { desc = "Disabled: click or Enter" })
map("n", "I", nop, { desc = "Disabled: click or Enter" })
map("n", "a", nop, { desc = "Disabled: click or Enter" })
map("n", "A", nop, { desc = "Disabled: click or Enter" })
map("n", "o", nop, { desc = "Disabled: use Enter at EOL" })
map("n", "O", nop, { desc = "Disabled: use Enter at EOL" })

-- Paste/yank/undo (use Cmd+V/C/Z instead)
map("n", "p", nop, { desc = "Disabled: use Cmd+V" })
map("n", "P", nop, { desc = "Disabled: use Cmd+V" })
map("n", "y", nop, { desc = "Disabled: use Cmd+C" })
map("n", "u", nop, { desc = "Disabled: use Cmd+Z" })
map("n", "U", nop, { desc = "Disabled" })

-- Other modifying commands
map("n", "~", nop, { desc = "Disabled" })
map("n", ".", nop, { desc = "Disabled" })

-- =============================================================================
-- macOS-style editing helpers
-- =============================================================================
-- Delete key deletes selection (Select mode)
map("s", "<Del>", "<C-o>d", { desc = "Delete selection" })
map("s", "<BS>", "<C-o>d", { desc = "Delete selection" })

-- Re-enable 'i' for entering insert mode (only explicit way in)
map("n", "i", "i", { desc = "Enter insert mode" })
