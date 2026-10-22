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
local mux_socket = wezterm.home_dir .. '/.local/share/wezterm/sock'
config.unix_domains = { { name = 'unix', socket_path = mux_socket } }
config.default_gui_startup_args = { 'connect', 'unix' }

-- Each session gets its own window: a separate GUI client attached to the same
-- mux server (one GUI process can only show one workspace at a time).
local act = wezterm.action
local wezterm_bin = wezterm.executable_dir .. '/wezterm'
local wezterm_app = wezterm.executable_dir:gsub('/Contents/MacOS$', '')
local function open_session_window(name)
  -- `open -n` starts a new instance via LaunchServices, so macOS focuses it
  wezterm.background_child_process {
    '/usr/bin/open', '-n', '-a', wezterm_app, '--args', 'connect', 'unix', '--workspace', name,
  }
end

-- A session window exits once its session is gone (last tab closed, `exit`,
-- killed elsewhere). Without this, the GUI would flip to another session.
local function session_gone(window)
  if window and window:active_workspace() ~= wezterm.GLOBAL.session_name then return true end
  for _, name in ipairs(wezterm.mux.get_workspace_names()) do
    if name == wezterm.GLOBAL.session_name then return false end
  end
  return true
end

wezterm.on('gui-attached', function()
  wezterm.GLOBAL.session_name = wezterm.mux.get_active_workspace()
  -- Cmd+N sessions (s1, s2, ...) get renamed after the folder you're in
  wezterm.GLOBAL.session_auto = wezterm.GLOBAL.session_name:match '^s%d+$' ~= nil
  if wezterm.GLOBAL.session_watch then return end
  wezterm.GLOBAL.session_watch = true
  local function check()
    if session_gone() then os.exit(0) end
    wezterm.time.call_after(0.1, check)
  end
  wezterm.time.call_after(0.1, check)
end)

local function session_panes()
  local name, ids = wezterm.mux.get_active_workspace(), {}
  for _, w in ipairs(wezterm.mux.all_windows()) do
    if w:get_workspace() == name then
      for _, t in ipairs(w:tabs()) do
        for _, p in ipairs(t:panes()) do table.insert(ids, tostring(p:pane_id())) end
      end
    end
  end
  return ids
end

-- `wezterm cli` against the mux server. Children inherit WEZTERM_UNIX_SOCKET
-- pointing at this GUI's own socket, which uses GUI-local pane ids.
local function mux_cli(args)
  return string.format("WEZTERM_UNIX_SOCKET='%s' '%s' cli %s", mux_socket, wezterm_bin, args)
end

-- End the whole session without flashing another one: look up the session's
-- server-side pane ids, quit this window, then a detached helper kills them.
local function end_session(window, pane)
  local name = window:active_workspace()
  local ok, out = wezterm.run_child_process { '/bin/sh', '-c', mux_cli 'list --format json' }
  local cmds = {}
  if ok then
    for _, p in ipairs(wezterm.json_parse(out)) do
      if p.workspace == name then
        table.insert(cmds, mux_cli('kill-pane --pane-id ' .. p.pane_id))
      end
    end
  end
  if #cmds > 0 then
    wezterm.background_child_process { '/bin/sh', '-c', 'sleep 0.3; ' .. table.concat(cmds, '; ') }
  end
  window:perform_action(act.QuitApplication, pane)
end

-- Auto-name: rename an auto-named session after its active pane's folder
wezterm.on('update-status', function(window, pane)
  if not wezterm.GLOBAL.session_auto then return end
  local cwd = pane:get_current_working_dir()
  if not cwd then return end
  local path = (cwd.file_path or tostring(cwd)):gsub('/$', '')
  local base = path == wezterm.home_dir and '~' or (path:match '([^/]+)$' or '~')
  local current = window:active_workspace()
  if current == base or current:match('^' .. base:gsub('%p', '%%%0') .. '%-%d+$') then return end
  local taken = {}
  for _, name in ipairs(wezterm.mux.get_workspace_names()) do taken[name] = true end
  local name, i = base, 2
  while taken[name] do name = base .. '-' .. i; i = i + 1 end
  wezterm.mux.rename_workspace(current, name)
  wezterm.GLOBAL.session_name = name
end)

config.keys = {
  -- Closing: Cmd+W window (session keeps running), Cmd+X pane, Cmd+Shift+X session
  { key = 'w', mods = 'CMD', action = act.QuitApplication },
  { key = 'x', mods = 'CMD', action = wezterm.action_callback(function(window, pane)
      if #session_panes() <= 1 then  -- last pane: just close the window
        return window:perform_action(act.QuitApplication, pane)
      end
      -- asks first if something other than a shell is running
      window:perform_action(act.CloseCurrentPane { confirm = true }, pane)
  end) },
  { key = '(', mods = 'CMD|SHIFT', action = act.MoveTabRelative(-1) },
  { key = ')', mods = 'CMD|SHIFT', action = act.MoveTabRelative(1) },
  { key = 'd', mods = 'CMD',       action = act.SplitHorizontal { domain = 'CurrentPaneDomain' } },
  { key = 'd', mods = 'CMD|SHIFT', action = act.SplitVertical { domain = 'CurrentPaneDomain' } },
  { key = 'Enter', mods = 'CMD|SHIFT', action = act.TogglePaneZoomState },
  { key = 'l', mods = 'CMD|SHIFT', action = act.ShowLauncher },
  { key = 'p', mods = 'CMD|SHIFT', action = act.ActivateCommandPalette },
  -- Sessions (workspaces) — one window per session, nothing switches in place
  { key = 's', mods = 'CMD|SHIFT', action = wezterm.action_callback(function(window, pane)
      local current = wezterm.mux.get_active_workspace()
      local choices = {}
      for _, name in ipairs(wezterm.mux.get_workspace_names()) do
        if name ~= current then table.insert(choices, { id = name, label = name }) end
      end
      window:perform_action(act.InputSelector {
        title = 'Open session in new window',
        fuzzy = true,
        choices = choices,
        action = wezterm.action_callback(function(_, _, id)
          if id then open_session_window(id) end
        end),
      }, pane)
  end) },
  -- One session per window: Cmd+N opens a new auto-named session (rename: Cmd+Shift+R)
  { key = 'n', mods = 'CMD', action = wezterm.action_callback(function()
      local taken = {}
      for _, name in ipairs(wezterm.mux.get_workspace_names()) do taken[name] = true end
      local i = 1
      while taken['s' .. i] do i = i + 1 end
      open_session_window('s' .. i)
  end) },
  { key = 'n', mods = 'CMD|SHIFT', action = act.PromptInputLine {
      description = 'New session name:',
      action = wezterm.action_callback(function(_, _, line)
        if line and #line > 0 then open_session_window(line) end
      end),
  } },
  { key = 'r', mods = 'CMD|SHIFT', action = act.PromptInputLine {
      description = 'Rename session:',
      action = wezterm.action_callback(function(_, _, line)
        if line and #line > 0 then
          wezterm.mux.rename_workspace(wezterm.mux.get_active_workspace(), line)
          wezterm.GLOBAL.session_name = line
          wezterm.GLOBAL.session_auto = false
        end
      end),
  } },
  { key = 'q', mods = 'CMD|SHIFT', action = act.DetachDomain { DomainName = 'unix' } },
  -- Kill the current session (all its panes) and close its window
  { key = 'x', mods = 'CMD|SHIFT', action = act.PromptInputLine {
      description = 'Kill current session? (y/N)',
      action = wezterm.action_callback(function(window, pane, line)
        if not line or line:lower() ~= 'y' then return end
        end_session(window, pane)
      end),
  } },
  -- macOS-style line editing (zsh binds these in .zshrc)
  { key = 'LeftArrow',  mods = 'CMD', action = act.SendString '\x1b[H' },     -- line start
  { key = 'RightArrow', mods = 'CMD', action = act.SendString '\x1b[F' },     -- line end
  { key = 'Backspace',  mods = 'CMD', action = act.SendString '\x15' },       -- delete to line start
  { key = 'LeftArrow',  mods = 'OPT', action = act.SendString '\x1b[1;3D' },  -- word back
  { key = 'RightArrow', mods = 'OPT', action = act.SendString '\x1b[1;3C' },  -- word forward
  { key = 'Backspace',  mods = 'OPT', action = act.SendString '\x1b\x7f' },   -- delete word
  { key = 'Enter', mods = 'ALT',   action = act.SendString '\x1b[13;3u' },  -- nvim checkbox toggle
}

return config
