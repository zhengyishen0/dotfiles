local wezterm = require 'wezterm'
local act = wezterm.action
local config = wezterm.config_builder()

-- =============================================================================
-- APPEARANCE
-- =============================================================================

-- Color scheme (popular options: "Tokyo Night", "Catppuccin Mocha", "Dracula", "rose-pine")
config.color_scheme = 'Tokyo Night'

-- Font
config.font = wezterm.font('JetBrains Mono', { weight = 'Medium' })
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
config.max_fps = 120
config.animation_fps = 120

-- =============================================================================
-- MUX SERVER (Persistence)
-- =============================================================================

config.unix_domains = {
  { name = 'unix' },
}
config.default_gui_startup_args = { 'connect', 'unix' }

-- =============================================================================
-- LEADER KEY (like tmux prefix)
-- =============================================================================

-- Leader: Ctrl+Space
config.leader = { key = 'Space', mods = 'CTRL', timeout_milliseconds = 1000 }

-- =============================================================================
-- KEYBINDINGS
-- =============================================================================

config.keys = {
  -- =====================
  -- PANE: Split
  -- =====================
  -- Leader + | or \ = split right
  { key = '|', mods = 'LEADER|SHIFT', action = act.SplitHorizontal { domain = 'CurrentPaneDomain' } },
  { key = '\\', mods = 'LEADER', action = act.SplitHorizontal { domain = 'CurrentPaneDomain' } },
  -- Leader + - = split down
  { key = '-', mods = 'LEADER', action = act.SplitVertical { domain = 'CurrentPaneDomain' } },

  -- Cmd+D / Cmd+Shift+D (iTerm2 style)
  { key = 'd', mods = 'CMD', action = act.SplitHorizontal { domain = 'CurrentPaneDomain' } },
  { key = 'd', mods = 'CMD|SHIFT', action = act.SplitVertical { domain = 'CurrentPaneDomain' } },

  -- =====================
  -- PANE: Navigate
  -- =====================
  -- Leader + h/j/k/l (vim style)
  { key = 'h', mods = 'LEADER', action = act.ActivatePaneDirection 'Left' },
  { key = 'j', mods = 'LEADER', action = act.ActivatePaneDirection 'Down' },
  { key = 'k', mods = 'LEADER', action = act.ActivatePaneDirection 'Up' },
  { key = 'l', mods = 'LEADER', action = act.ActivatePaneDirection 'Right' },

  -- Cmd+Option+Arrow (macOS style)
  { key = 'LeftArrow', mods = 'CMD|OPT', action = act.ActivatePaneDirection 'Left' },
  { key = 'RightArrow', mods = 'CMD|OPT', action = act.ActivatePaneDirection 'Right' },
  { key = 'UpArrow', mods = 'CMD|OPT', action = act.ActivatePaneDirection 'Up' },
  { key = 'DownArrow', mods = 'CMD|OPT', action = act.ActivatePaneDirection 'Down' },

  -- Cmd+[ / Cmd+] to cycle panes
  { key = '[', mods = 'CMD', action = act.ActivatePaneDirection 'Prev' },
  { key = ']', mods = 'CMD', action = act.ActivatePaneDirection 'Next' },

  -- =====================
  -- PANE: Resize
  -- =====================
  -- Leader + Arrow
  { key = 'LeftArrow', mods = 'LEADER', action = act.AdjustPaneSize { 'Left', 5 } },
  { key = 'RightArrow', mods = 'LEADER', action = act.AdjustPaneSize { 'Right', 5 } },
  { key = 'UpArrow', mods = 'LEADER', action = act.AdjustPaneSize { 'Up', 5 } },
  { key = 'DownArrow', mods = 'LEADER', action = act.AdjustPaneSize { 'Down', 5 } },

  -- =====================
  -- PANE: Other
  -- =====================
  -- Leader + z or Leader + Space = zoom/maximize pane
  { key = 'z', mods = 'LEADER', action = act.TogglePaneZoomState },
  { key = 'Space', mods = 'LEADER', action = act.TogglePaneZoomState },
  -- Leader + x = close pane
  { key = 'x', mods = 'LEADER', action = act.CloseCurrentPane { confirm = true } },
  -- Cmd+W = close pane (no confirm for speed)
  { key = 'w', mods = 'CMD', action = act.CloseCurrentPane { confirm = false } },

  -- =====================
  -- TAB: Management
  -- =====================
  -- Cmd+T = new tab
  { key = 't', mods = 'CMD', action = act.SpawnTab 'CurrentPaneDomain' },
  -- Leader + c = new tab (tmux style)
  { key = 'c', mods = 'LEADER', action = act.SpawnTab 'CurrentPaneDomain' },
  -- Cmd+Shift+[ / ] = switch tabs
  { key = '{', mods = 'CMD|SHIFT', action = act.ActivateTabRelative(-1) },
  { key = '}', mods = 'CMD|SHIFT', action = act.ActivateTabRelative(1) },
  -- Leader + ] / [ = next/prev tab
  { key = ']', mods = 'LEADER', action = act.ActivateTabRelative(1) },
  { key = '[', mods = 'LEADER', action = act.ActivateTabRelative(-1) },
  -- Cmd+( / Cmd+) = move tab left/right
  { key = '9', mods = 'CMD|SHIFT', action = act.MoveTabRelative(-1) },
  { key = '0', mods = 'CMD|SHIFT', action = act.MoveTabRelative(1) },
  -- Cmd+1-9 = go to tab
  { key = '1', mods = 'CMD', action = act.ActivateTab(0) },
  { key = '2', mods = 'CMD', action = act.ActivateTab(1) },
  { key = '3', mods = 'CMD', action = act.ActivateTab(2) },
  { key = '4', mods = 'CMD', action = act.ActivateTab(3) },
  { key = '5', mods = 'CMD', action = act.ActivateTab(4) },
  { key = '6', mods = 'CMD', action = act.ActivateTab(5) },
  { key = '7', mods = 'CMD', action = act.ActivateTab(6) },
  { key = '8', mods = 'CMD', action = act.ActivateTab(7) },
  { key = '9', mods = 'CMD', action = act.ActivateTab(-1) },  -- Last tab

  -- =====================
  -- COPY MODE
  -- =====================
  -- Leader + [ = enter copy mode (tmux style)
  { key = '[', mods = 'LEADER', action = act.ActivateCopyMode },

  -- =====================
  -- SCROLL
  -- =====================
  { key = 'k', mods = 'OPT', action = act.ScrollByLine(-3) },
  { key = 'j', mods = 'OPT', action = act.ScrollByLine(3) },

  -- =====================
  -- macOS-style LINE EDITING (for shell)
  -- =====================
  -- Opt+Left/Right = move by word
  { key = 'LeftArrow', mods = 'OPT', action = act.SendKey { key = 'b', mods = 'ALT' } },
  { key = 'RightArrow', mods = 'OPT', action = act.SendKey { key = 'f', mods = 'ALT' } },
  -- Cmd+Left/Right = start/end of line
  { key = 'LeftArrow', mods = 'CMD', action = act.SendKey { key = 'a', mods = 'CTRL' } },
  { key = 'RightArrow', mods = 'CMD', action = act.SendKey { key = 'e', mods = 'CTRL' } },
  -- Opt+Backspace = delete word back
  { key = 'Backspace', mods = 'OPT', action = act.SendKey { key = 'w', mods = 'CTRL' } },
  -- Cmd+Backspace = delete to start of line
  { key = 'Backspace', mods = 'CMD', action = act.SendKey { key = 'u', mods = 'CTRL' } },
  -- Shift+Enter = insert newline (without executing)
  { key = 'Enter', mods = 'SHIFT', action = act.SendString '\n' },

  -- =====================
  -- SEARCH
  -- =====================
  { key = 'f', mods = 'CMD', action = act.Search 'CurrentSelectionOrEmptyString' },

  -- =====================
  -- QUICK SELECT (URLs, paths, etc.)
  -- =====================
  { key = 'u', mods = 'LEADER', action = act.QuickSelect },
  { key = 'f', mods = 'OPT', action = act.QuickSelect },  -- Opt+F

  -- =====================
  -- WINDOWS & SESSIONS
  -- =====================
  -- Cmd+n = new session (prompts for name)
  { key = 'n', mods = 'CMD', action = act.PromptInputLine {
    description = 'Enter new session name:',
    action = wezterm.action_callback(function(window, pane, line)
      if line then
        window:perform_action(act.SwitchToWorkspace { name = line }, pane)
      end
    end),
  }},
  -- Cmd+Shift+N = new window
  { key = 'n', mods = 'CMD|SHIFT', action = act.SpawnWindow },
  -- Opt+Tab / Opt+Shift+Tab = switch session next/prev
  { key = 'Tab', mods = 'OPT', action = act.SwitchWorkspaceRelative(1) },
  { key = 'Tab', mods = 'OPT|SHIFT', action = act.SwitchWorkspaceRelative(-1) },
  -- Leader + s = show workspace launcher (backup)
  { key = 's', mods = 'LEADER', action = act.ShowLauncherArgs { flags = 'FUZZY|WORKSPACES' } },
  -- Opt+r = rename tab, Opt+R = rename session
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
  -- MISC
  -- =====================
  -- Cmd+, = open config
  { key = ',', mods = 'CMD', action = act.SpawnCommandInNewTab {
    cwd = wezterm.home_dir,
    args = { '/opt/homebrew/bin/nvim', wezterm.config_file },
  }},
  -- Cmd+Shift+R = reload config
  { key = 'r', mods = 'CMD|SHIFT', action = act.ReloadConfiguration },
  -- Leader + r = reload config
  { key = 'r', mods = 'LEADER', action = act.ReloadConfiguration },
  -- Cmd+Enter = toggle fullscreen
  { key = 'Enter', mods = 'CMD', action = act.ToggleFullScreen },
  -- Leader + d = detach (useful for mux)
  { key = 'd', mods = 'LEADER', action = act.DetachDomain 'CurrentPaneDomain' },

  -- Clear scrollback
  { key = 'k', mods = 'CMD', action = act.ClearScrollback 'ScrollbackAndViewport' },

  -- Command palette (launcher style)
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

return config
