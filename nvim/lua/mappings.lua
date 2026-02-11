require "nvchad.mappings"

local map = vim.keymap.set

-- Override NvChad C-h/j/k/l with tmux-aware navigation
map("n", "<C-h>", "<cmd>TmuxNavigateLeft<CR>", { desc = "Navigate left" })
map("n", "<C-j>", "<cmd>TmuxNavigateDown<CR>", { desc = "Navigate down" })
map("n", "<C-k>", "<cmd>TmuxNavigateUp<CR>", { desc = "Navigate up" })
map("n", "<C-l>", "<cmd>TmuxNavigateRight<CR>", { desc = "Navigate right" })

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
-- Floating terminal windows
-- =============================================================================


-- Space-j: floating lazyjj (auto-closes when lazyjj exits)
map({ "n", "t" }, "<leader>j", function()
  local dir = vim.fn.expand("%:p:h")
  local buf = vim.api.nvim_create_buf(false, true)
  local width = math.floor(vim.o.columns * 0.75)
  local height = math.floor(vim.o.lines * 0.75)
  local win = vim.api.nvim_open_win(buf, true, {
    relative = "editor",
    width = width,
    height = height,
    row = math.floor((vim.o.lines - height) / 2),
    col = math.floor((vim.o.columns - width) / 2),
    border = "rounded",
    style = "minimal",
  })

  vim.fn.termopen("cd " .. vim.fn.shellescape(dir) .. " && lazyjj", {
    on_exit = function()
      vim.schedule(function()
        if vim.api.nvim_win_is_valid(win) then
          vim.api.nvim_win_close(win, true)
        end
        if vim.api.nvim_buf_is_valid(buf) then
          vim.api.nvim_buf_delete(buf, { force = true })
        end
      end)
    end,
  })
  vim.cmd("startinsert")
end, { desc = "Floating lazyjj" })

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
