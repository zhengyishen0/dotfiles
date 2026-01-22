#!/bin/bash
# System setup script for new machines
# Usage: setup (after sourcing .zshrc)

DOTFILES=~/dotfiles

echo "=== System Setup ==="
echo ""

# 1. Install Homebrew if not present
if ! command -v brew &>/dev/null; then
    echo "[1/5] Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

    # Add Homebrew to PATH for this session
    if [[ -f /opt/homebrew/bin/brew ]]; then
        eval "$(/opt/homebrew/bin/brew shellenv)"
    elif [[ -f /usr/local/bin/brew ]]; then
        eval "$(/usr/local/bin/brew shellenv)"
    fi
    echo ""
else
    echo "[1/5] Homebrew already installed."
fi

# 2. Install Homebrew packages
echo "[2/5] Installing Homebrew packages..."
if [[ -f $DOTFILES/brew/Brewfile ]]; then
    brew bundle install --file=$DOTFILES/brew/Brewfile
else
    echo "Error: $DOTFILES/brew/Brewfile not found"
    exit 1
fi
echo ""

# 3. GitHub Apps (interactive) - read from apps/github.txt
echo "[3/5] GitHub Apps..."
if [[ -f $DOTFILES/apps/github.txt ]]; then
    while IFS='|' read -r name app_path dmg_url volume_name; do
        [[ "$name" =~ ^#.*$ || -z "$name" ]] && continue
        if [[ ! -e "$app_path" ]]; then
            read -p "Install $name from GitHub? [y/N] " -n 1 -r
            echo ""
            if [[ $REPLY =~ ^[Yy]$ ]]; then
                echo "Downloading $name..."
                curl -L "$dmg_url" -o "/tmp/$name.dmg"
                hdiutil attach "/tmp/$name.dmg" -quiet
                cp -R "/Volumes/$volume_name/$name.app" /Applications/
                hdiutil detach "/Volumes/$volume_name" -quiet
                rm "/tmp/$name.dmg"
                echo "$name installed!"
            fi
        else
            echo "$name already installed, skipping."
        fi
    done < $DOTFILES/apps/github.txt
fi
echo ""

# 4. Stow dotfiles
echo "[4/5] Stowing dotfiles..."
cd $DOTFILES
# Auto-detect stow packages (folders containing dotfiles)
for dir in */; do
    if ls "$dir"/.* 1>/dev/null 2>&1; then
        stow -v "${dir%/}" 2>&1 | grep -v "BUG"
    fi
done
cd - > /dev/null

# Manual symlinks (non-stow structure)
mkdir -p ~/.config
ln -sf $DOTFILES/ghostty ~/.config/ghostty
echo ""

# 5. Manual install reminders - read from apps/manual.txt
echo "[5/5] Manual Install Required:"
echo ""
if [[ -f $DOTFILES/apps/manual.txt ]]; then
    mas_apps=()
    other_apps=()
    while IFS='|' read -r name source; do
        [[ "$name" =~ ^#.*$ || -z "$name" ]] && continue
        if [[ "$source" == "Mac App Store" ]]; then
            mas_apps+=("$name")
        else
            other_apps+=("$name")
        fi
    done < $DOTFILES/apps/manual.txt

    if [[ ${#mas_apps[@]} -gt 0 ]]; then
        echo "  Mac App Store:"
        for app in "${mas_apps[@]}"; do
            echo "    - $app"
        done
        echo ""
    fi

    if [[ ${#other_apps[@]} -gt 0 ]]; then
        echo "  Other:"
        for app in "${other_apps[@]}"; do
            echo "    - $app"
        done
        echo ""
    fi
fi

echo "  Vimium C:"
echo "    - Import search engines from: $DOTFILES/vimium/search-engines.txt"
echo "    - Import custom keys from:    $DOTFILES/vimium/custom-keys.txt"
echo ""

echo "=== Setup Complete ==="
echo "Run: source ~/.zshrc"
