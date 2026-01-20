# Dotfiles

Personal macOS configuration managed with GNU Stow.

## Quick Start

```bash
git clone https://github.com/zhengyishen0/dotfiles.git ~/dotfiles && source ~/dotfiles/zsh/.zshrc && setup
```

## Structure

```
dotfiles/
├── apps/
│   ├── github.txt           # GitHub apps (DMG install)
│   └── manual.txt           # Manual install reminders
├── brew/
│   └── Brewfile             # Homebrew packages & casks
├── scripts/
│   ├── setup.sh             # System setup script
│   └── sync-tmux.sh         # Tmux config sync
├── vimium/
│   ├── search-engines.txt   # Vimium C search engines
│   └── custom-keys.txt      # Vimium C key mappings
├── zsh/
│   └── .zshrc               # Shell config
├── git/
│   └── .gitconfig           # Git config
├── tmux/
│   └── .tmux.conf           # Tmux config
├── ghostty/
│   └── config               # Ghostty terminal config
└── README.md
```

## Adding Apps

| Type | File |
|------|------|
| Homebrew | `brew/Brewfile` |
| GitHub DMG | `apps/github.txt` |
| Manual | `apps/manual.txt` |

### Format Examples

**apps/github.txt:**
```
# name|app_path|dmg_url|volume_name
AppName|/Applications/AppName.app|https://github.com/.../App.dmg|AppName
```

**apps/manual.txt:**
```
# name|source
AppName|Mac App Store
AnotherApp|Manual
```

## Commands

| Command | Description |
|---------|-------------|
| `setup` | Full system setup |
| `sync-tmux push` | Push tmux config to git |
| `sync-tmux pull` | Pull and reload tmux config |

## Tmux Keybindings

**Prefix:** `Ctrl+Space`

| Category | Keys | Action |
|----------|------|--------|
| **Navigation** | | |
| | `Ctrl+←/→` | Switch pane |
| | `Ctrl+Option+←/→` | Switch window |
| | `Ctrl+Option+↑/↓` | Switch session |
| **Pane** | | |
| | `Ctrl+\` | Split horizontal |
| | `Ctrl+-` | Split vertical |
| | `Ctrl+Shift+←/→/↑/↓` | Resize pane |
| | `prefix Space` | Zoom toggle |
| **Window** | | |
| | `prefix n` | New window |
| | `prefix x` | Kill window |
| | `prefix r` | Rename window |
| **Copy Mode** | | |
| | `Opt+←/→` | Word move |
| | `Ctrl+←/→` | Line start/end |
| | `Opt+Shift+←/→` | Select word |
| | `Ctrl+Shift+←/→` | Select to line |
| | Drag | Select & copy |
| | `y` | Copy |
| | Right-click | Paste |

## Shell Aliases

| Alias | Command |
|-------|---------|
| `ls` | `eza` |
| `cat` | `bat` |
| `du` | `dust` |
| `df` | `duf` |
| `ps` | `procs` |
| `y` | `yazi` (cd on exit) |
