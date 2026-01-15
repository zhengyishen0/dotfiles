# Dotfiles

Personal macOS configuration managed with GNU Stow.

## Quick Start (New Machine)

```bash
git clone https://github.com/zhengyishen0/dotfiles.git ~/dotfiles && source ~/dotfiles/zsh/.zshrc && setup
```

This single command will:
1. Install Homebrew (if not present)
2. Install all packages from Brewfile (50+ formulae, 20+ casks)
3. Prompt to install GitHub apps (boringNotch, etc.)
4. Stow all dotfiles (zsh, git, tmux)
5. Show manual install reminders

## Structure

```
dotfiles/
├── apps/
│   ├── github.txt            # GitHub apps (DMG install)
│   └── manual.txt            # Manual install reminders
├── brew/
│   └── Brewfile              # Homebrew packages & casks
├── vimium/
│   ├── search-engines.txt    # Vimium C search engines
│   └── custom-keys.txt       # Vimium C key mappings
├── zsh/
│   └── .zshrc                # Zsh config + setup function
├── git/
│   └── .gitconfig
├── tmux/
│   └── .tmux.conf
└── README.md
```

## Adding New Apps

### Homebrew Apps
Edit `brew/Brewfile`:
```ruby
brew "package-name"
cask "app-name"
```

### GitHub Apps (DMG)
Edit `apps/github.txt`:
```
# Format: name|app_path|dmg_url|volume_name
AppName|/Applications/AppName.app|https://github.com/.../AppName.dmg|AppName
```

### Manual Apps
Edit `apps/manual.txt`:
```
# Format: name|source
AppName|Mac App Store
AnotherApp|Manual
```

## Manual Steps After Setup

### Vimium C
1. Open Vimium C settings
2. Copy `~/dotfiles/vimium/search-engines.txt` → Custom search engines
3. Copy `~/dotfiles/vimium/custom-keys.txt` → Custom key mappings

### Mac App Store
- Grab2Text
- rcmd

### Other
- Hex, Frost, FreeGecko, Handy, Countdown, Monocle, Affinity

## Tools & Aliases

### Shell Init (auto-configured)
| Tool | Purpose |
|------|---------|
| zoxide | Smart cd (`z` command) |
| fzf | Fuzzy finder |
| yazi | File manager (`y` command, cd on exit) |

### Modern CLI Aliases
| Alias | Command | Description |
|-------|---------|-------------|
| `ls` | `eza` | Better ls |
| `cat` | `bat` | Syntax highlighting |
| `du` | `dust` | Visual disk usage |
| `df` | `duf` | Better df |
| `ps` | `procs` | Better ps |

### Tmux Copy Mode
| Action | Effect |
|--------|--------|
| Scroll | Enter copy-mode, auto-exit at bottom |
| Drag | Select and copy to clipboard |
| `Opt + ←/→` | Word navigation |
| `Ctrl + ←/→` | Line start/end |
| `Opt+Shift + ←/→` | Select word (hold to extend) |
| `Ctrl+Shift + ←/→` | Select to line start/end |
| `y` | Copy to clipboard |
| `Escape` | Exit copy-mode |
| Right-click | Paste |

## Updating

```bash
cd ~/dotfiles
git add -A && git commit -m "Update" && git push
```
