# Dotfiles

Personal configuration files managed with GNU Stow.

## Structure

```
dotfiles/
├── brew/
│   └── Brewfile              # Homebrew packages & casks
├── vimium/
│   ├── search-engines.txt    # Vimium C search engines
│   └── custom-keys.txt       # Vimium C key mappings
├── zsh/
│   └── .zshrc                # Zsh configuration
├── git/
│   └── .gitconfig            # Git configuration
├── tmux/
│   └── .tmux.conf            # Tmux configuration
└── README.md
```

## Quick Setup

```bash
# Clone and run setup
git clone https://github.com/YOUR_USERNAME/dotfiles.git ~/dotfiles
source ~/dotfiles/zsh/.zshrc
setup
```

The `setup` function will:
1. Install all Homebrew packages from Brewfile
2. Prompt to install GitHub apps (boringNotch)
3. Stow all dotfiles (creates symlinks)
4. Show reminders for manual installs

## Manual Setup

### 1. Install Homebrew Packages

```bash
brew bundle install --file=~/dotfiles/brew/Brewfile
```

### 2. Stow Dotfiles

```bash
cd ~/dotfiles
stow zsh git tmux
```

### 3. Vimium C

Import configurations manually in Vimium C settings:
- **Search engines**: Copy from `vimium/search-engines.txt`
- **Key mappings**: Copy from `vimium/custom-keys.txt`

### 4. Manual Installs

**Mac App Store:**
- Grab2Text
- rcmd

**GitHub Releases:**
- [boringNotch](https://github.com/TheBoredTeam/boring.notch/releases)

**Other:**
- Hex, Frost, FreeGecko, Handy, Countdown, Monocle, Affinity

## Updating

### Sync dotfiles changes

```bash
cd ~/dotfiles
git add -A
git commit -m "Update configs"
git push
```

### Update boringNotch

```bash
update_boringnotch
```

### Update Homebrew packages

```bash
brew bundle install --file=~/dotfiles/brew/Brewfile
```

## Tools Requiring Shell Init

These are automatically configured in `.zshrc`:

| Tool | Init Command | Purpose |
|------|--------------|---------|
| zoxide | `eval "$(zoxide init zsh)"` | Smart cd |
| fzf | `source <(fzf --zsh)` | Fuzzy finder |
| yazi | `y` function | File manager with cd-on-exit |

## Modern CLI Aliases

When installed, these aliases are activated:

| Alias | Command | Description |
|-------|---------|-------------|
| `ls` | `eza` | Better ls with git integration |
| `cat` | `bat` | Syntax highlighting |
| `du` | `dust` | Visual disk usage |
| `df` | `duf` | Better df |
| `ps` | `procs` | Better ps |
| `y` | `yazi` | File manager (cd on exit) |
