#!/bin/bash
# System setup script for new machines
# Usage: setup (after sourcing .zshrc)

DOTFILES=~/dotfiles

echo "=== System Setup ==="
echo ""

# 1. Install Homebrew if not present
if ! command -v brew &>/dev/null; then
    echo "[1/6] Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

    if [[ -f /opt/homebrew/bin/brew ]]; then
        eval "$(/opt/homebrew/bin/brew shellenv)"
    elif [[ -f /usr/local/bin/brew ]]; then
        eval "$(/usr/local/bin/brew shellenv)"
    fi
    echo ""
else
    echo "[1/6] Homebrew already installed."
fi

# 2. Install Homebrew packages
echo "[2/6] Installing Homebrew packages..."
if [[ -f $DOTFILES/brew/Brewfile ]]; then
    brew bundle install --file=$DOTFILES/brew/Brewfile
else
    echo "Error: $DOTFILES/brew/Brewfile not found"
    exit 1
fi
echo ""

# 3. GitHub Releases Apps (latest versions)
echo "[3/6] GitHub Releases Apps..."
if [[ -f $DOTFILES/apps/releases.txt ]]; then
    while IFS='|' read -r name app_path repo pattern; do
        [[ "$name" =~ ^#.*$ || -z "$name" ]] && continue
        if [[ ! -e "$app_path" ]]; then
            read -p "Install $name from GitHub? [y/N] " -n 1 -r
            echo ""
            if [[ $REPLY =~ ^[Yy]$ ]]; then
                echo "Downloading $name..."
                gh release download --repo "$repo" --pattern "$pattern" -D /tmp --clobber
                dmg_file=$(ls /tmp/*.dmg 2>/dev/null | head -1)
                if [[ -n "$dmg_file" ]]; then
                    hdiutil attach "$dmg_file" -quiet
                    volume=$(ls /Volumes | grep -i "${name}" | head -1)
                    if [[ -n "$volume" ]]; then
                        cp -R "/Volumes/$volume/$name.app" /Applications/
                        hdiutil detach "/Volumes/$volume" -quiet
                    fi
                    rm "$dmg_file"
                    echo "$name installed!"
                fi
            fi
        else
            echo "$name already installed, skipping."
        fi
    done < $DOTFILES/apps/releases.txt
fi
echo ""

# 4. Backup Apps (from dotfiles releases)
echo "[4/6] Backup Apps..."
if [[ -f $DOTFILES/apps/backup.txt ]]; then
    while IFS='|' read -r name pattern; do
        [[ "$name" =~ ^#.*$ || -z "$name" ]] && continue
        if [[ ! -e "/Applications/$name.app" ]]; then
            read -p "Install $name from backup? [y/N] " -n 1 -r
            echo ""
            if [[ $REPLY =~ ^[Yy]$ ]]; then
                echo "Downloading $name..."
                gh release download apps --repo zhengyishen0/dotfiles --pattern "$pattern" -D /tmp --clobber
                unzip -o "/tmp/$pattern" -d /
                rm "/tmp/$pattern"
                echo "$name installed!"
            fi
        else
            echo "$name already installed, skipping."
        fi
    done < $DOTFILES/apps/backup.txt
fi
echo ""

# 5. Stow dotfiles
echo "[5/6] Stowing dotfiles..."
cd $DOTFILES
for dir in */; do
    if ls "$dir"/.* 1>/dev/null 2>&1; then
        stow -v "${dir%/}" 2>&1 | grep -v "BUG"
    fi
done
cd - > /dev/null

mkdir -p ~/.config
ln -sf $DOTFILES/ghostty ~/.config/ghostty

# Karabiner config
if [[ -f $DOTFILES/karabiner/karabiner.json ]]; then
    mkdir -p ~/.config/karabiner/assets/complex_modifications
    if [[ -f ~/.config/karabiner/karabiner.json && ! -L ~/.config/karabiner/karabiner.json ]]; then
        echo "Karabiner config exists, backing up..."
        cp ~/.config/karabiner/karabiner.json ~/.config/karabiner/karabiner.json.bak
    fi
    ln -sf $DOTFILES/karabiner/karabiner.json ~/.config/karabiner/karabiner.json
    # Complex modifications presets
    for f in $DOTFILES/karabiner/assets/complex_modifications/*.json; do
        ln -sf "$f" ~/.config/karabiner/assets/complex_modifications/
    done
    echo "Karabiner config linked."
fi
echo ""

# 6. Manual install reminders
echo "[6/6] Manual Install Required:"
echo ""
if [[ -f $DOTFILES/apps/manual.txt ]]; then
    while IFS='|' read -r name source; do
        [[ "$name" =~ ^#.*$ || -z "$name" ]] && continue
        echo "  - $name ($source)"
    done < $DOTFILES/apps/manual.txt
fi
echo ""

echo "  Vimium C:"
echo "    - Import search engines from: $DOTFILES/vimium/search-engines.txt"
echo "    - Import custom keys from:    $DOTFILES/vimium/custom-keys.txt"
echo ""

echo "=== Setup Complete ==="
echo "Run: source ~/.zshrc"
