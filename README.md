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
│   ├── releases.txt         # GitHub releases (latest)
│   ├── backup.txt           # Backed up apps (dotfiles releases)
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
├── vim/
│   └── .vimrc               # Vim config
├── nano/
│   └── .nanorc              # Nano config
├── karabiner/
│   ├── karabiner.json       # Main config (symlinked)
│   └── README.md             # Setup instructions
├── ghostty/
│   └── config               # Ghostty terminal config
└── README.md
```

## Apps

| Type | File | Install Method |
|------|------|----------------|
| Homebrew | `brew/Brewfile` | `brew bundle` |
| GitHub Releases | `apps/releases.txt` | `gh release download` |
| Backed Up | `apps/backup.txt` | `gh release download` from dotfiles |
| Manual | `apps/manual.txt` | Manual reminder |

### Format Examples

**apps/releases.txt:**
```
# name|app_path|repo|pattern
Frost|/Applications/Frost.app|zhengyishen0/frost-app|*.dmg
```

**apps/backup.txt:**
```
# name|pattern
rcmd|rcmd.zip
```

**apps/manual.txt:**
```
# name|source
Hex|Manual
```

## Setup Steps

1. Install Homebrew (auto)
2. Install brew packages
3. Install GitHub releases apps
4. Install backed up apps
5. Stow dotfiles
6. Manual install reminders
