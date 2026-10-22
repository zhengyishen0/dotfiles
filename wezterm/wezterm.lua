-- WezTerm config — styled to match Ghostty (Tokyo Night, JetBrains Mono, translucent)
local wezterm = require 'wezterm'
local config = wezterm.config_builder()

-- Theme -----------------------------------------------------------------------
local scheme_name = 'Tokyo Night'
local scheme = wezterm.color.get_builtin_schemes()[scheme_name]
config.color_scheme = scheme_name

local bg      = scheme.background   -- #1a1b26
local bg_dark = '#16161e'
local fg      = scheme.foreground   -- #c0caf5
local muted   = '#565f89'
local accent  = '#7aa2f7'
local purple  = '#bb9af7'

-- Font ------------------------------------------------------------------------
config.font = wezterm.font_with_fallback {
  { family = 'JetBrainsMono Nerd Font', weight = 'Medium' },
  'PingFang SC',
}
config.font_size = 14
config.line_height = 1.1
config.harfbuzz_features = { 'calt=1', 'liga=1' }

-- Window ----------------------------------------------------------------------
config.window_background_opacity = 0.95
config.macos_window_background_blur = 30
config.window_decorations = 'RESIZE|INTEGRATED_BUTTONS'
config.integrated_title_button_style = 'MacOsNative'
config.window_padding = { left = 14, right = 14, top = 10, bottom = 8 }
config.initial_cols = 140
config.initial_rows = 40
config.window_close_confirmation = 'NeverPrompt'
config.adjust_window_size_when_changing_font_size = false
config.native_macos_fullscreen_mode = true

-- Dim inactive panes so focus is obvious
config.inactive_pane_hsb = { saturation = 0.8, brightness = 0.7 }

-- Cursor ----------------------------------------------------------------------
config.default_cursor_style = 'BlinkingBar'
config.cursor_blink_rate = 600
config.cursor_blink_ease_in = 'Constant'
config.cursor_blink_ease_out = 'Constant'

-- Tab bar ---------------------------------------------------------------------
config.use_fancy_tab_bar = true
config.tab_bar_at_bottom = false
config.hide_tab_bar_if_only_one_tab = false
config.show_new_tab_button_in_tab_bar = false
config.tab_max_width = 32
config.window_frame = {
  font = wezterm.font { family = 'JetBrainsMono Nerd Font', weight = 'Bold' },
  font_size = 12.5,
  active_titlebar_bg = bg_dark,
  inactive_titlebar_bg = bg_dark,
}
config.colors = {
  split = muted,
  tab_bar = {
    background = bg_dark,
    inactive_tab_edge = bg_dark,
  },
}

local function tab_title(tab)
  local title = tab.tab_title
  if title and #title > 0 then return title end
  local pane = tab.active_pane
  local process = (pane.foreground_process_name or ''):match('([^/]+)$') or ''
  local cwd = pane.current_working_dir
  local dir = cwd and (cwd.file_path or tostring(cwd)):gsub('/$', ''):match('([^/]+)$') or ''
  if process == 'zsh' or process == 'fish' or process == '' then
    return dir ~= '' and dir or pane.title
  end
  return process .. ' · ' .. dir
end

wezterm.on('format-tab-title', function(tab, _, _, _, hover, max_width)
  local title = wezterm.truncate_right(tab_title(tab), max_width - 6)
  local index = tostring(tab.tab_index + 1)
  if tab.active_pane.is_zoomed then title = title .. ' 󰁌' end

  if tab.is_active then
    return {
      { Background = { Color = bg } },
      { Foreground = { Color = accent } },
      { Text = '  ' .. index .. '  ' },
      { Foreground = { Color = fg } },
      { Text = title .. '  ' },
    }
  end
  return {
    { Background = { Color = hover and '#1f2335' or bg_dark } },
    { Foreground = { Color = muted } },
    { Text = '  ' .. index .. '  ' .. title .. '  ' },
  }
end)

-- Right status: workspace + time
wezterm.on('update-status', function(window, _)
  window:set_right_status(wezterm.format {
    { Foreground = { Color = purple } },
    { Text = '  ' .. window:active_workspace() .. '  ' },
    { Foreground = { Color = muted } },
    { Text = wezterm.strftime '%H:%M' .. '  ' },
  })
end)

-- Behaviour (mirrors Ghostty) -------------------------------------------------
config.send_composed_key_when_left_alt_is_pressed = false  -- Option acts as Alt
config.send_composed_key_when_right_alt_is_pressed = true
config.scrollback_lines = 20000
config.audible_bell = 'Disabled'
config.visual_bell = {
  fade_in_duration_ms = 75, fade_out_duration_ms = 150,
  target = 'CursorColor',
}

-- Copy on select → system clipboard
config.mouse_bindings = {
  {
    event = { Up = { streak = 1, button = 'Left' } },
    mods = 'NONE',
    action = wezterm.action.CompleteSelectionOrOpenLinkAtMouseCursor 'ClipboardAndPrimarySelection',
  },
}

-- Session persistence (tmux-style) -------------------------------------------
-- All shells live in a background `wezterm-mux-server`. The GUI is just a client:
-- Cmd+Q detaches, reopening WezTerm reattaches with every process still running.
-- Workspaces are the "sessions" (Cmd+Shift+S to switch / create).
config.unix_domains = { { name = 'unix' } }
config.default_gui_startup_args = { 'connect', 'unix' }

local act = wezterm.action
config.keys = {
  { key = 'w', mods = 'CMD',       action = act.CloseCurrentPane { confirm = false } },
  { key = 'w', mods = 'CMD|SHIFT', action = act.CloseCurrentTab { confirm = false } },
  { key = '(', mods = 'CMD|SHIFT', action = act.MoveTabRelative(-1) },
  { key = ')', mods = 'CMD|SHIFT', action = act.MoveTabRelative(1) },
  { key = 'd', mods = 'CMD',       action = act.SplitHorizontal { domain = 'CurrentPaneDomain' } },
  { key = 'd', mods = 'CMD|SHIFT', action = act.SplitVertical { domain = 'CurrentPaneDomain' } },
  { key = 'Enter', mods = 'CMD|SHIFT', action = act.TogglePaneZoomState },
  { key = 'l', mods = 'CMD|SHIFT', action = act.ShowLauncher },
  { key = 'p', mods = 'CMD|SHIFT', action = act.ActivateCommandPalette },
  -- Sessions (workspaces): pick an existing one, or type a new name to create it
  { key = 's', mods = 'CMD|SHIFT', action = act.ShowLauncherArgs { flags = 'FUZZY|WORKSPACES' } },
  { key = 'n', mods = 'CMD|SHIFT', action = act.PromptInputLine {
      description = 'New session name:',
      action = wezterm.action_callback(function(window, pane, line)
        if line and #line > 0 then
          window:perform_action(act.SwitchToWorkspace { name = line }, pane)
        end
      end),
  } },
  { key = 'r', mods = 'CMD|SHIFT', action = act.PromptInputLine {
      description = 'Rename session:',
      action = wezterm.action_callback(function(_, _, line)
        if line and #line > 0 then
          wezterm.mux.rename_workspace(wezterm.mux.get_active_workspace(), line)
        end
      end),
  } },
  { key = 'q', mods = 'CMD|SHIFT', action = act.DetachDomain { DomainName = 'unix' } },
  { key = 'Enter', mods = 'ALT',   action = act.SendString '\x1b[13;3u' },  -- nvim checkbox toggle
}

return config
