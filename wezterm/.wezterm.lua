local wezterm = require 'wezterm'
local act = wezterm.action
local config = wezterm.config_builder()

-- =============================================================================
-- SMART SPLITS (vim-aware Ctrl+hjkl navigation via wezterm plugin)
-- =============================================================================

local smart_splits = wezterm.plugin.require('https://github.com/mrjones2014/smart-splits.nvim')

-- =============================================================================
-- APPEARANCE
-- =============================================================================

-- Color scheme (popular options: "Tokyo Night", "Catppuccin Mocha", "Dracula", "rose-pine")
config.color_scheme = 'Tokyo Night'

-- Font (with CJK fallback)
config.font = wezterm.font_with_fallback({
  { family = 'JetBrains Mono', weight = 'Medium' },
  'Hiragino Sans GB',      -- macOS Chinese
  'Noto Sans CJK SC',      -- Linux/cross-platform
})
config.font_size = 14.0

-- Window
config.window_decorations = 'RESIZE'  -- Remove title bar, keep resize
config.window_background_opacity = 0.95
config.macos_window_background_blur = 30
config.window_padding = {
  left = 0,
  right = 0,
  top = 0,
  bottom = 0,
}

-- Tab bar
config.hide_tab_bar_if_only_one_tab = false
config.tab_bar_at_bottom = false
config.use_fancy_tab_bar = true
config.show_new_tab_button_in_tab_bar = false
config.tab_max_width = 32

-- Tokyo Night colors
local bg = '#1a1b26'
local primary = '#7aa2f7'
local fg = '#c0caf5'
local grey = '#565f89'
local dark_grey = '#24283b'

config.colors = {
  tab_bar = {
    background = bg,
  },
}

-- Fancy tab bar frame
config.window_frame = {
  font = wezterm.font('JetBrains Mono', { weight = 'Medium' }),
  font_size = 12.0,
  active_titlebar_bg = bg,
  inactive_titlebar_bg = bg,
}

-- Shell
config.default_prog = { '/opt/homebrew/bin/nu' }

-- Cursor
config.default_cursor_style = 'SteadyBar'

-- Command palette styling (Tokyo Night)
config.command_palette_font_size = 14.0
config.command_palette_rows = 16
config.command_palette_bg_color = 'rgba(26, 27, 38, 0.95)'
config.command_palette_fg_color = '#c0caf5'

-- Misc
config.scrollback_lines = 10000
config.enable_scroll_bar = false
config.adjust_window_size_when_changing_font_size = false
config.window_close_confirmation = 'NeverPrompt'

-- =============================================================================
-- SSH DOMAINS (Remote connections)
-- =============================================================================

-- WSL via Tailscale SSH (uses ~/.ssh/config ProxyCommand)
config.ssh_domains = {
  {
    name = 'wsl',
    remote_address = 'asus-wsl-ubuntu',
    username = 'ubuntu',
    multiplexing = 'WezTerm',  -- runs wezterm mux server on remote
  },
}

-- =============================================================================
-- KEYBINDINGS
-- =============================================================================

config.keys = {
  -- =====================
  -- PANE: Split (Cmd+D / Cmd+Shift+D)
  -- =====================
  { key = 'd', mods = 'CMD', action = act.SplitHorizontal { domain = 'CurrentPaneDomain' } },
  { key = 'd', mods = 'CMD|SHIFT', action = act.SplitVertical { domain = 'CurrentPaneDomain' } },

  -- =====================
  -- PANE: Navigate (Ctrl+hjkl handled by smart-splits plugin)
  -- =====================
  { key = 'LeftArrow', mods = 'CMD|OPT', action = act.ActivatePaneDirection 'Left' },
  { key = 'RightArrow', mods = 'CMD|OPT', action = act.ActivatePaneDirection 'Right' },
  { key = 'UpArrow', mods = 'CMD|OPT', action = act.ActivatePaneDirection 'Up' },
  { key = 'DownArrow', mods = 'CMD|OPT', action = act.ActivatePaneDirection 'Down' },
  { key = '[', mods = 'CMD', action = act.ActivatePaneDirection 'Prev' },
  { key = ']', mods = 'CMD', action = act.ActivatePaneDirection 'Next' },

  -- =====================
  -- PANE: Other (resize via Opt+hjkl from smart-splits)
  -- =====================
  { key = 'w', mods = 'CMD', action = act.CloseCurrentPane { confirm = false } },
  { key = 'Enter', mods = 'CMD', action = act.TogglePaneZoomState },

  -- =====================
  -- TAB: Management
  -- =====================
  { key = 't', mods = 'CMD', action = act.SpawnTab 'CurrentPaneDomain' },
  { key = '{', mods = 'CMD|SHIFT', action = act.ActivateTabRelative(-1) },
  { key = '}', mods = 'CMD|SHIFT', action = act.ActivateTabRelative(1) },
  { key = ',', mods = 'CTRL', action = act.ActivateTabRelative(-1) },
  { key = '.', mods = 'CTRL', action = act.ActivateTabRelative(1) },
  { key = '9', mods = 'CMD|SHIFT', action = act.MoveTabRelative(-1) },
  { key = '0', mods = 'CMD|SHIFT', action = act.MoveTabRelative(1) },
  { key = '1', mods = 'CMD', action = act.ActivateTab(0) },
  { key = '2', mods = 'CMD', action = act.ActivateTab(1) },
  { key = '3', mods = 'CMD', action = act.ActivateTab(2) },
  { key = '4', mods = 'CMD', action = act.ActivateTab(3) },
  { key = '5', mods = 'CMD', action = act.ActivateTab(4) },
  { key = '6', mods = 'CMD', action = act.ActivateTab(5) },
  { key = '7', mods = 'CMD', action = act.ActivateTab(6) },
  { key = '8', mods = 'CMD', action = act.ActivateTab(7) },
  { key = '9', mods = 'CMD', action = act.ActivateTab(-1) },

  -- =====================
  -- SCROLL (PageUp/PageDown)
  -- =====================
  { key = 'PageUp', mods = 'NONE', action = act.ScrollByPage(-1) },
  { key = 'PageDown', mods = 'NONE', action = act.ScrollByPage(1) },

  -- =====================
  -- macOS-style LINE EDITING (for shell)
  -- =====================
  { key = 'LeftArrow', mods = 'OPT', action = act.SendKey { key = 'b', mods = 'ALT' } },
  { key = 'RightArrow', mods = 'OPT', action = act.SendKey { key = 'f', mods = 'ALT' } },
  { key = ',', mods = 'OPT', action = act.SendKey { key = 'b', mods = 'ALT' } },
  { key = '.', mods = 'OPT', action = act.SendKey { key = 'f', mods = 'ALT' } },
  { key = 'LeftArrow', mods = 'CMD', action = act.SendKey { key = 'a', mods = 'CTRL' } },
  { key = 'RightArrow', mods = 'CMD', action = act.SendKey { key = 'e', mods = 'CTRL' } },
  { key = '<', mods = 'OPT|SHIFT', action = act.SendKey { key = 'Home' } },
  { key = '>', mods = 'OPT|SHIFT', action = act.SendKey { key = 'End' } },
  { key = 'Backspace', mods = 'OPT', action = act.SendKey { key = 'w', mods = 'CTRL' } },
  { key = 'Backspace', mods = 'CMD', action = act.SendKey { key = 'u', mods = 'CTRL' } },
  { key = 'Enter', mods = 'SHIFT', action = act.SendString '\n' },

  -- =====================
  -- SEARCH & QUICK SELECT
  -- =====================
  { key = 'f', mods = 'CMD', action = act.Search 'CurrentSelectionOrEmptyString' },
  { key = 'f', mods = 'OPT', action = act.QuickSelect },

  -- =====================
  -- WORKSPACES & SESSIONS
  -- =====================
  { key = 'n', mods = 'CMD', action = act.PromptInputLine {
    description = 'Enter new session name:',
    action = wezterm.action_callback(function(window, pane, line)
      if line then
        window:perform_action(act.SwitchToWorkspace { name = line }, pane)
      end
    end),
  }},
  { key = 'n', mods = 'CMD|SHIFT', action = act.SpawnWindow },
  { key = 'Tab', mods = 'OPT', action = act.SwitchWorkspaceRelative(1) },
  { key = 'Tab', mods = 'OPT|SHIFT', action = act.SwitchWorkspaceRelative(-1) },
  { key = 's', mods = 'CMD|SHIFT', action = act.ShowLauncherArgs { flags = 'FUZZY|WORKSPACES' } },
  { key = 'r', mods = 'OPT', action = act.PromptInputLine {
    description = 'Rename tab:',
    action = wezterm.action_callback(function(window, pane, line)
      if line then
        window:active_tab():set_title(line)
      end
    end),
  }},
  { key = 'r', mods = 'OPT|SHIFT', action = act.PromptInputLine {
    description = 'Rename session:',
    action = wezterm.action_callback(function(window, pane, line)
      if line then
        wezterm.mux.rename_workspace(window:active_workspace(), line)
      end
    end),
  }},

  -- =====================
  -- PASSTHROUGH (Cmd → Ctrl for apps)
  -- =====================
  { key = 'z', mods = 'CMD', action = act.SendKey { key = 'z', mods = 'CTRL' } },
  { key = 's', mods = 'CMD', action = act.SendKey { key = 's', mods = 'CTRL' } },

  -- =====================
  -- MISC
  -- =====================
  { key = ',', mods = 'CMD', action = act.SpawnCommandInNewTab {
    cwd = wezterm.home_dir,
    args = { '/opt/homebrew/bin/nvim', wezterm.config_file },
  }},
  { key = 'r', mods = 'CMD|SHIFT', action = act.ReloadConfiguration },
  { key = 'Enter', mods = 'CMD|SHIFT', action = act.ToggleFullScreen },
  { key = 'k', mods = 'CMD', action = act.ClearScrollback 'ScrollbackAndViewport' },
  { key = 'p', mods = 'CMD|SHIFT', action = act.ShowLauncherArgs { flags = 'FUZZY|COMMANDS' } },
}

-- =============================================================================
-- STATUS BAR
-- =============================================================================

-- Clear left status (remove session name from front)
wezterm.on('update-left-status', function(window, pane)
  window:set_left_status('')
end)

wezterm.on('update-right-status', function(window, pane)
  local date = wezterm.strftime '%H:%M'
  local workspace = window:active_workspace()

  -- Zoom indicator
  local zoom = ''
  local tab = window:active_tab()
  if tab then
    for _, p in ipairs(tab:panes_with_info()) do
      if p.is_zoomed then
        zoom = '[Z] '
        break
      end
    end
  end

  window:set_right_status(wezterm.format {
    { Foreground = { Color = '#f7768e' } },
    { Text = zoom },
    { Foreground = { Color = '#7aa2f7' } },
    { Attribute = { Underline = 'Single' } },
    { Text = '[' .. workspace .. ']' },
    { Attribute = { Underline = 'None' } },
    { Text = '  ' },
    { Foreground = { Color = '#565f89' } },
    { Text = date .. ' ' },
  })
end)


-- Tab title with powerline style (Tokyo Night)
wezterm.on('format-tab-title', function(tab, tabs, panes, cfg, hover, max_width)
  local LEFT_END = utf8.char(0xE0B6)   --
  local RIGHT_END = utf8.char(0xE0B4)  --

  -- Colors
  local bg = '#1a1b26'
  local primary = '#7aa2f7'
  local grey = '#565f89'

  -- Icons
  local icon_active = wezterm.nerdfonts.md_ghost
  local icon_inactive = wezterm.nerdfonts.md_ghost_off_outline

  -- Get title (remove any icons from pane title)
  local title = tab.tab_title
  if not title or #title == 0 then
    title = tab.active_pane.title
  end
  -- Remove common icons/prefixes from title
  title = title:gsub('^[%s]*[^\x00-\x7F]+[%s]*', '')
  title = wezterm.truncate_right(title, max_width - 6)

  -- Minimum width padding
  local min_width = 6
  if #title < min_width then
    title = title .. string.rep(' ', min_width - #title)
  end

  local tab_bg, tab_fg, icon
  if tab.is_active then
    tab_bg = primary
    tab_fg = bg
    icon = icon_active
  else
    tab_bg = bg
    tab_fg = grey
    icon = icon_inactive
  end

  return {
    { Background = { Color = bg } },
    { Foreground = { Color = tab_bg } },
    { Text = LEFT_END },
    { Background = { Color = tab_bg } },
    { Foreground = { Color = tab_fg } },
    { Text = ' ' .. icon .. ' ' .. title .. ' ' },
    { Background = { Color = bg } },
    { Foreground = { Color = tab_bg } },
    { Text = RIGHT_END },
  }
end)

-- Auto-copy selection to clipboard, then clear highlight
config.mouse_bindings = {
  {
    event = { Up = { streak = 1, button = 'Left' } },
    mods = 'NONE',
    action = act.Multiple {
      act.CompleteSelectionOrOpenLinkAtMouseCursor 'Clipboard',
      act.ClearSelection,
    },
  },
}

-- Apply smart-splits navigation and resize
smart_splits.apply_to_config(config, {
  direction_keys = { 'h', 'j', 'k', 'l' },
  modifiers = {
    move = 'CTRL',
    resize = 'META',
  },
})

return config
