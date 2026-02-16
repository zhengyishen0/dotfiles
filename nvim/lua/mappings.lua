require "nvchad.mappings"

local map = vim.keymap.set

-- Override NvChad C-h/j/k/l with tmux-aware navigation (all modes)
map({ "n", "i", "t" }, "<C-h>", "<cmd>TmuxNavigateLeft<CR>", { desc = "Navigate left" })
map({ "n", "i", "t" }, "<C-j>", "<cmd>TmuxNavigateDown<CR>", { desc = "Navigate down" })
map({ "n", "i", "t" }, "<C-k>", "<cmd>TmuxNavigateUp<CR>", { desc = "Navigate up" })
map({ "n", "i", "t" }, "<C-l>", "<cmd>TmuxNavigateRight<CR>", { desc = "Navigate right" })

-- Remove NvChad Ctrl defaults
map("n", "<C-c>", "<Nop>", { desc = "Disabled" })
map("i", "<C-b>", "<Nop>", { desc = "Disabled: use Cmd+Left" })
map("i", "<C-e>", "<Nop>", { desc = "Disabled: use Cmd+Right" })

-- Ctrl shortcuts (all modes including terminal)
map({ "n", "i", "v", "s", "t" }, "<C-s>", "<Cmd>w<CR>", { desc = "Save" })
map({ "n", "i", "v", "s", "t" }, "<C-x>", function() require("nvchad.tabufline").close_buffer() end, { desc = "Close buffer" })
map({ "n", "i", "v", "s", "t" }, "<C-q>", "<Cmd>qa<CR>", { desc = "Quit all" })

-- Leader shortcuts (nvim views)
-- Custom: j (lazyjj), k (smart term), u (tmux), y (yazi), Tab (cycle splits)
-- Available: a, i, l, o, q, s, z
-- NvChad uses: b, c, d, e, f, g, h, m, n, p, r, t, v, w, x
map("n", "<leader>y", "<Cmd>Yazi<CR>", { desc = "Yazi (q to close)" })

map("n", ";", ":", { desc = "CMD enter command mode" })
map("n", "<leader><Tab>", "<C-w>w", { desc = "Cycle splits" })

-- Terminal toggles: Ctrl + -/\/=
map({ "n", "t" }, "<C-->", function()
  require("nvchad.term").toggle { pos = "sp", id = "htoggleTerm" }
end, { desc = "Terminal horizontal" })

map({ "n", "t" }, "<C-\\>", function()
  require("nvchad.term").toggle { pos = "vsp", id = "vtoggleTerm" }
end, { desc = "Terminal vertical" })

map({ "n", "t" }, "<C-=>", function()
  require("nvchad.term").toggle { pos = "float", id = "floatTerm" }
end, { desc = "Terminal float" })

-- =============================================================================
-- Floating tmux terminal (leader-t)
-- =============================================================================

_G.tmux_state = { buf = nil, win = nil }
local tmux_state = _G.tmux_state

local function tmux_cleanup()
  if tmux_state.win and vim.api.nvim_win_is_valid(tmux_state.win) then
    vim.api.nvim_win_close(tmux_state.win, true)
  end
  if tmux_state.buf and vim.api.nvim_buf_is_valid(tmux_state.buf) then
    vim.api.nvim_buf_delete(tmux_state.buf, { force = true })
  end
  tmux_state.win = nil
  tmux_state.buf = nil
end

_G.toggle_tmux = function() end
local function toggle_tmux()
  -- If open, close it
  if tmux_state.win and vim.api.nvim_win_is_valid(tmux_state.win) then
    tmux_cleanup()
    return
  end

  tmux_cleanup()

  -- Create centered floating window (90% of screen)
  local width = math.floor(vim.o.columns * 0.9)
  local height = math.floor(vim.o.lines * 0.9)
  local col = math.floor((vim.o.columns - width) / 2)
  local row = math.floor((vim.o.lines - height) / 3)

  tmux_state.buf = vim.api.nvim_create_buf(false, true)
  tmux_state.win = vim.api.nvim_open_win(tmux_state.buf, true, {
    relative = "editor",
    width = width,
    height = height,
    col = col,
    row = row,
    style = "minimal",
    border = "rounded",
  })

  vim.fn.termopen("tmux attach || tmux new", {
    on_exit = function()
      vim.schedule(tmux_cleanup)
    end,
  })
  vim.cmd("startinsert")

  -- Auto-enter insert mode when entering buffer
  vim.api.nvim_create_autocmd("BufEnter", {
    buffer = tmux_state.buf,
    callback = function()
      if tmux_state.buf and vim.api.nvim_buf_is_valid(tmux_state.buf) then
        vim.cmd("startinsert")
      end
    end,
  })
end

_G.toggle_tmux = toggle_tmux
map("n", "<leader>u", toggle_tmux, { desc = "Toggle tmux" })

-- =============================================================================
-- Markdown: toggle checkbox
-- =============================================================================
local function toggle_checkbox()
  local line = vim.api.nvim_get_current_line()
  local new_line
  if line:match("%- %[ %]") then
    new_line = line:gsub("%- %[ %]", "- [x]", 1)
  elseif line:match("%- %[x%]") then
    new_line = line:gsub("%- %[x%]", "- [ ]", 1)
  else
    return -- not a checkbox line
  end
  vim.api.nvim_set_current_line(new_line)
end
map({ "n", "i" }, "<M-CR>", toggle_checkbox, { desc = "Toggle checkbox" })

-- Move line/selection up/down (Alt+j/k)
map("n", "<M-k>", ":m .-2<CR>==", { desc = "Move line up" })
map("n", "<M-j>", ":m .+1<CR>==", { desc = "Move line down" })
map("i", "<M-k>", "<C-o>:m .-2<CR><C-o>==", { desc = "Move line up" })
map("i", "<M-j>", "<C-o>:m .+1<CR><C-o>==", { desc = "Move line down" })
map("v", "<M-k>", ":m '<-2<CR>gv=gv", { desc = "Move selection up" })
map("v", "<M-j>", ":m '>+1<CR>gv=gv", { desc = "Move selection down" })

-- Indent/dedent (Opt+h/l)
map("n", "<M-h>", "<<", { desc = "Dedent" })
map("n", "<M-l>", ">>", { desc = "Indent" })
map("i", "<M-h>", "<C-d>", { desc = "Dedent" })
map("i", "<M-l>", "<C-t>", { desc = "Indent" })
map("v", "<M-h>", "<gv", { desc = "Dedent selection" })
map("v", "<M-l>", ">gv", { desc = "Indent selection" })

-- Line start/end (Shift+h/l)
map({ "n", "v" }, "H", "^", { desc = "Line start" })
map({ "n", "v" }, "L", "$", { desc = "Line end" })

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

-- Paragraph navigation (Cmd+Up/Down via Ghostty Ctrl+Home/End remap)
map({ "n", "v" }, "<C-Home>", "{", { desc = "Paragraph up" })
map({ "n", "v" }, "<C-End>", "}", { desc = "Paragraph down" })
map("i", "<C-Home>", "<C-o>{", { desc = "Paragraph up" })
map("i", "<C-End>", "<C-o>}", { desc = "Paragraph down" })

-- Shift+arrow = select (Select mode - typing replaces selection)
map("n", "<S-Left>", "gh<Left>", { desc = "Select left" })
map("n", "<S-Right>", "gh<Right>", { desc = "Select right" })
map("n", "<S-Up>", "gh<Up>", { desc = "Select up" })
map("n", "<S-Down>", "gh<Down>", { desc = "Select down" })
map("s", "<S-Left>", "<C-o><Left>", { desc = "Extend left" })
map("s", "<S-Right>", "<C-o><Right>", { desc = "Extend right" })
map("s", "<S-Up>", "<C-o><Up>", { desc = "Extend up" })
map("s", "<S-Down>", "<C-o><Down>", { desc = "Extend down" })

-- Shift+Opt+arrow = select by word
map("n", "\x1b[1;4D", "vb<C-g>", { desc = "Select word back" })   -- Shift+Alt+Left
map("n", "\x1b[1;4C", "vw<C-g>", { desc = "Select word forward" }) -- Shift+Alt+Right
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

-- Cmd+C/X (copy/cut with system clipboard)
map("v", "<D-c>", '"+y', { desc = "Copy to clipboard" })
map("v", "<D-x>", '"+d', { desc = "Cut to clipboard" })

-- Cmd+S (save and exit to normal mode)
map("n", "<D-s>", "<Cmd>w<CR>", { desc = "Save" })
map({ "i", "v", "s" }, "<D-s>", "<Esc><Cmd>w<CR>", { desc = "Save" })

-- Cmd+Q = default Ghostty quit (no nvim mapping)

-- Cmd+W (close buffer)
map({ "n", "i", "v", "s" }, "<D-w>", function()
  require("nvchad.tabufline").close_buffer()
end, { desc = "Close buffer" })

-- leader+j already mapped below (lazyjj)

-- Opt+Backspace = delete word backward
map("i", "<M-BS>", "<C-w>", { desc = "Delete word backward" })

-- =============================================================================
-- Bottom terminal lazyjj (simple toggle)
-- =============================================================================

_G.lazyjj_state = { buf = nil, win = nil }
local lazyjj_state = _G.lazyjj_state

-- File watcher for auto-refresh
local jj_watcher = nil
local debounce_timer = nil

local function start_jj_watch()
  if jj_watcher then return end
  local jj_path = vim.fn.getcwd() .. "/.jj"
  if vim.fn.isdirectory(jj_path) == 0 then return end

  jj_watcher = vim.uv.new_fs_event()
  jj_watcher:start(jj_path, { recursive = true }, function()
    vim.schedule(function()
      -- Debounce: cancel pending refresh, schedule new one
      if debounce_timer then
        debounce_timer:stop()
      end
      debounce_timer = vim.defer_fn(function()
        if lazyjj_state.buf and vim.api.nvim_buf_is_valid(lazyjj_state.buf) then
          local chan = vim.bo[lazyjj_state.buf].channel
          if chan and chan > 0 then
            vim.api.nvim_chan_send(chan, "R")
          end
        end
        debounce_timer = nil
      end, 500)
    end)
  end)
end

local function stop_jj_watch()
  if debounce_timer then
    debounce_timer:stop()
    debounce_timer = nil
  end
  if jj_watcher then
    jj_watcher:stop()
    jj_watcher = nil
  end
end

local function lazyjj_cleanup()
  stop_jj_watch()
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
  start_jj_watch()
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
map("n", "<leader>j", toggle_lazyjj, { desc = "Toggle lazyjj" })

-- map({ "n", "i", "v" }, "<C-s>", "<cmd> w <cr>")

-- =============================================================================
-- Disable single-letter commands (macOS-style: click to type, select + type)
-- =============================================================================
local nop = "<Nop>"
-- Delete/change commands
map("n", "x", function()
  require("nvchad.tabufline").close_buffer()
end, { desc = "Close buffer" })
map("n", "X", nop, { desc = "Disabled" })
map("n", "d", nop, { desc = "Disabled" })
map("n", "D", nop, { desc = "Disabled" })
map("n", "c", nop, { desc = "Disabled" })
map("n", "C", nop, { desc = "Disabled" })
map("n", "r", nop, { desc = "Disabled" })
map("n", "R", nop, { desc = "Disabled" })
map("n", "J", "}", { desc = "Next paragraph" })
map("n", "K", "{", { desc = "Previous paragraph" })
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
map("n", "u", nop, { desc = "Disabled" })
map({ "n", "v" }, "U", "~", { desc = "Toggle case" })
map("s", "U", "<C-g>~", { desc = "Toggle case" })
map("n", "<", "<<", { desc = "Dedent line" })
map("n", ">", ">>", { desc = "Indent line" })
map("v", "<", nop, { desc = "Disabled" })
map("v", ">", nop, { desc = "Disabled" })
map({ "n", "v" }, "gu", nop, { desc = "Disabled" })
map({ "n", "v" }, "gU", nop, { desc = "Disabled" })

-- Other modifying commands
map("n", "~", nop, { desc = "Disabled" })
map("n", ".", nop, { desc = "Disabled" })

-- Restore default vim behavior
map("n", "m", "m", { desc = "Set mark" })

-- =============================================================================
-- macOS-style editing helpers
-- =============================================================================
-- Shift+Enter = new line below and insert (with autolist support for markdown)
map("n", "<S-CR>", "o", { desc = "New line below, insert" })
map("i", "<S-CR>", function()
  if vim.bo.filetype == "markdown" then
    local autolist_ok, _ = pcall(require, "autolist")
    if autolist_ok then
      return "<CR><cmd>AutolistNewBullet<CR>"
    end
  end
  return "<C-o>o"
end, { expr = true, desc = "New line below (autolist in md)" })

-- Delete/Backspace
map("n", "<BS>", '"_cl', { desc = "Delete letter, insert" })
map("n", "<M-BS>", '"_cw', { desc = "Delete word, insert" })
map("n", "\x1b[127;2u", "cc", { desc = "Delete line, insert" })           -- Shift+BS (Ghostty: shift+backspace=csi:127;2u)
map("i", "\x1b[127;2u", "<C-o>cc", { desc = "Delete line, stay insert" }) -- Shift+BS

-- Delete key deletes selection (Select mode)
map("s", "<Del>", "<C-o>d", { desc = "Delete selection" })
map("s", "<BS>", "<C-o>d", { desc = "Delete selection" })

-- Enter to insert mode (smart: 'a' at word end, 'i' otherwise)
map("n", "<CR>", function()
  local col = vim.fn.col('.')
  local line = vim.fn.getline('.')

  -- At or past EOL → append
  if col >= #line then return 'a' end

  -- Next char is non-word → word end → append
  local next = line:sub(col + 1, col + 1)
  if next:match('[^%w_]') then return 'a' end

  -- Everything else → insert
  return 'i'
end, { expr = true, desc = "Smart insert mode" })

-- Smart terminal toggle (leader+k)
-- lazyjj → vertical | terminal/nvimtree → float | editor → horizontal
map({ "n", "t" }, "<leader>k", function()
  local buf = vim.api.nvim_get_current_buf()

  -- In lazyjj → toggle vertical
  if lazyjj_state.buf and buf == lazyjj_state.buf then
    require("nvchad.term").toggle { pos = "vsp", id = "vtoggleTerm" }
    return
  end

  -- In terminal or NvimTree → toggle float
  if vim.bo[buf].buftype == "terminal" or vim.bo[buf].filetype == "NvimTree" then
    require("nvchad.term").toggle { pos = "float", id = "floatTerm" }
    return
  end

  -- In editor → toggle horizontal
  require("nvchad.term").toggle { pos = "sp", id = "htoggleTerm" }
end, { desc = "Smart terminal toggle" })

-- Close command history window (q:) with Esc
vim.api.nvim_create_autocmd("CmdwinEnter", {
  callback = function()
    vim.keymap.set("n", "<Esc>", "<Cmd>q<CR>", { buffer = true, desc = "Close cmdwin" })
  end,
})
