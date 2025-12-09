#!/bin/bash
# Bidirectional sync script for tmux config
# Usage:
#   ./sync-tmux.sh push   - Push local changes to git
#   ./sync-tmux.sh pull   - Pull from git and apply

set -e

DOTFILES_DIR="$HOME/dotfiles"
TMUX_CONF="$HOME/.tmux.conf"
DOTFILES_TMUX="$DOTFILES_DIR/tmux/.tmux.conf"

cd "$DOTFILES_DIR"

if [[ "$1" == "push" ]]; then
    echo "📤 Pushing tmux config to git..."

    # Copy current config to dotfiles (in case edited directly)
    if [[ -L "$TMUX_CONF" ]]; then
        echo "✓ Config is symlinked (stow managed)"
    else
        echo "⚠️  Config is not symlinked, copying to dotfiles..."
        cp "$TMUX_CONF" "$DOTFILES_TMUX"
    fi

    # Git operations
    git add tmux/.tmux.conf

    if git diff --staged --quiet; then
        echo "✓ No changes to push"
    else
        echo "Changes detected:"
        git diff --staged --stat
        read -p "Commit message (or Enter for default): " msg
        msg=${msg:-"Update tmux config"}
        git commit -m "$msg"
        git push
        echo "✓ Pushed to GitHub"
    fi

elif [[ "$1" == "pull" ]]; then
    echo "📥 Pulling tmux config from git..."

    # Check for local changes
    if [[ -f "$TMUX_CONF" ]] && ! [[ -L "$TMUX_CONF" ]]; then
        if ! diff -q "$TMUX_CONF" "$DOTFILES_TMUX" >/dev/null 2>&1; then
            echo "⚠️  Local changes detected!"
            read -p "Backup current config before pulling? [Y/n] " backup
            if [[ ! "$backup" =~ ^[Nn]$ ]]; then
                cp "$TMUX_CONF" "$TMUX_CONF.backup.$(date +%Y%m%d_%H%M%S)"
                echo "✓ Backed up to ~/.tmux.conf.backup.*"
            fi
        fi
    fi

    # Pull from git
    git pull

    # Restow (safe even if already stowed)
    stow -R tmux

    # Reload tmux if running
    if tmux info &>/dev/null; then
        tmux source-file "$TMUX_CONF"
        echo "✓ Reloaded tmux config"
    fi

    echo "✓ Pulled from GitHub and applied"

else
    echo "Usage: $0 {push|pull}"
    echo ""
    echo "  push - Commit and push local tmux config to GitHub"
    echo "  pull - Pull from GitHub and apply to local tmux"
    exit 1
fi
