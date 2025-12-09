# Dotfiles

Personal configuration files managed with GNU Stow.

## Setup on New Machine

```bash
# 1. Clone this repo
git clone https://github.com/YOUR_USERNAME/dotfiles.git ~/dotfiles

# 2. Install stow (if not installed)
brew install stow  # macOS
# sudo apt install stow  # Linux

# 3. Backup existing configs (optional)
mv ~/.tmux.conf ~/.tmux.conf.backup 2>/dev/null || true

# 4. Stow tmux config (creates symlinks)
cd ~/dotfiles
stow tmux

# 5. Install TPM (Tmux Plugin Manager)
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm

# 6. Start tmux and install plugins
tmux
# Press: prefix + I (capital I)
```

## Syncing Tmux Config

Use the bidirectional sync script:

```bash
# Push local changes to GitHub
~/dotfiles/sync-tmux.sh push

# Pull from GitHub and apply
~/dotfiles/sync-tmux.sh pull
```

## Manual Sync

```bash
# Push changes
cd ~/dotfiles
git add tmux/.tmux.conf
git commit -m "Update tmux config"
git push

# Pull changes
cd ~/dotfiles
git pull
stow -R tmux  # Restow to update symlinks
tmux source-file ~/.tmux.conf  # Reload if tmux is running
```

## Structure

```
dotfiles/
├── tmux/
│   └── .tmux.conf
├── sync-tmux.sh
└── README.md
```

## How Stow Works

Stow creates symlinks from `~/dotfiles/tmux/.tmux.conf` to `~/.tmux.conf`.

When you edit `~/.tmux.conf`, you're actually editing the file in the dotfiles repo, making it easy to commit and push changes.
