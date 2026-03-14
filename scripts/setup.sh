#!/bin/bash
# System setup script for new machines
# Usage: setup (after sourcing .zshrc)

DOTFILES=~/dotfiles

echo "=== System Setup ==="
echo ""

# 1. Install Homebrew if not present
if ! command -v brew &>/dev/null; then
    echo "[1/8] Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

    if [[ -f /opt/homebrew/bin/brew ]]; then
        eval "$(/opt/homebrew/bin/brew shellenv)"
    elif [[ -f /usr/local/bin/brew ]]; then
        eval "$(/usr/local/bin/brew shellenv)"
    fi
    echo ""
else
    echo "[1/8] Homebrew already installed."
fi

# 2. Install Homebrew packages
echo "[2/8] Installing Homebrew packages..."
if [[ -f $DOTFILES/brew/Brewfile ]]; then
    brew bundle install --file=$DOTFILES/brew/Brewfile
else
    echo "Error: $DOTFILES/brew/Brewfile not found"
    exit 1
fi
echo ""

# 3. Install Cargo packages
echo "[3/8] Installing Cargo packages..."
if command -v cargo &>/dev/null; then
    if [[ -f $DOTFILES/cargo/packages.txt ]]; then
        while IFS='#' read -r pkg comment; do
            pkg=$(echo "$pkg" | xargs)  # trim whitespace
            [[ "$pkg" =~ ^#.*$ || -z "$pkg" ]] && continue
            
            if cargo install --list | grep -q "^$pkg "; then
                echo "$pkg already installed, skipping."
            else
                read -p "Install $pkg? [y/N] " -n 1 -r
                echo ""
                if [[ $REPLY =~ ^[Yy]$ ]]; then
                    cargo install "$pkg"
                fi
            fi
        done < $DOTFILES/cargo/packages.txt
    else
        echo "No cargo packages file found at $DOTFILES/cargo/packages.txt"
    fi
else
    echo "Cargo not installed. Install Rust from https://rustup.rs/"
fi
echo ""

# 4. GitHub Releases Apps (latest versions)
echo "[4/8] GitHub Releases Apps..."
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

# 5. Backup Apps (from dotfiles releases)
echo "[5/8] Backup Apps..."
if [[ -f $DOTFILES/apps/backup.txt ]]; then
    while IFS='|' read -r name file install_cmd; do
        [[ "$name" =~ ^#.*$ || -z "$name" ]] && continue
        # Check if already installed (app or binary)
        if [[ -e "/Applications/$name.app" ]] || command -v "$name" &>/dev/null; then
            echo "$name already installed, skipping."
            continue
        fi
        read -p "Install $name from backup? [y/N] " -n 1 -r
        echo ""
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            echo "Downloading $name..."
            gh release download apps --repo zhengyishen0/dotfiles --pattern "$file" -D /tmp --clobber
            cd /tmp
            eval "$install_cmd"
            rm -f "/tmp/$file"
            echo "$name installed!"
            cd - > /dev/null
        fi
    done < $DOTFILES/apps/backup.txt
fi
echo ""

# 6. Stow dotfiles
echo "[6/8] Stowing dotfiles..."
cd $DOTFILES
for dir in */; do
    pkg="${dir%/}"
    # nvim needs special stow target, handled below
    [[ "$pkg" == "nvim" ]] && continue
    if ls "$dir"/.* 1>/dev/null 2>&1; then
        stow -v "$pkg" 2>&1 | grep -v "BUG"
    fi
done
cd - > /dev/null

mkdir -p ~/.config
ln -sf $DOTFILES/ghostty ~/.config/ghostty

# Neovim config (stow to ~/.config/nvim, not ~)
mkdir -p ~/.config/nvim
stow -v -t ~/.config/nvim nvim 2>&1 | grep -v "BUG"

# Nushell config
mkdir -p "$HOME/Library/Application Support/nushell"
ln -sf $DOTFILES/nu/env.nu "$HOME/Library/Application Support/nushell/env.nu"
ln -sf $DOTFILES/nu/config.nu "$HOME/Library/Application Support/nushell/config.nu"

# Helix config
mkdir -p ~/.config/helix
ln -sf $DOTFILES/helix/config.toml ~/.config/helix/config.toml

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

# Paneru config
if [[ -f $DOTFILES/paneru/paneru ]]; then
    if [[ -f ~/.paneru && ! -L ~/.paneru ]]; then
        echo "Paneru config exists, backing up..."
        cp ~/.paneru ~/.paneru.bak
    fi
    ln -sf $DOTFILES/paneru/paneru ~/.paneru
    echo "Paneru config linked."
fi

# Kanata config
if [[ -f $DOTFILES/kanata/kanata.kbd ]]; then
    mkdir -p ~/.config/kanata
    if [[ -f ~/.config/kanata/kanata.kbd && ! -L ~/.config/kanata/kanata.kbd ]]; then
        echo "Kanata config exists, backing up..."
        cp ~/.config/kanata/kanata.kbd ~/.config/kanata/kanata.kbd.bak
    fi
    ln -sf $DOTFILES/kanata/kanata.kbd ~/.config/kanata/kanata.kbd
    echo "Kanata config linked."
fi
echo ""

# 7. macOS app CLIs (wrapper scripts needed due to bundle restrictions)
echo "[7/8] Setting up macOS app CLIs..."
mkdir -p ~/.local/bin
if [[ -x /Applications/Tailscale.app/Contents/MacOS/Tailscale ]]; then
    printf '#!/bin/bash\n/Applications/Tailscale.app/Contents/MacOS/Tailscale "$@"\n' > ~/.local/bin/tailscale
    chmod +x ~/.local/bin/tailscale
    echo "Tailscale CLI wrapper created."
else
    echo "Tailscale not installed, skipping."
fi

# nnn config (binary installed from backup in step 4)
if [[ -f $DOTFILES/nnn/opener ]]; then
    mkdir -p ~/.config/nnn/plugins
    ln -sf $DOTFILES/nnn/opener ~/.config/nnn/opener
    ln -sf $DOTFILES/nnn/preview-tui ~/.config/nnn/plugins/preview-tui
    echo "nnn config linked."
fi
echo ""

# 8. Manual install reminders
echo "[8/8] Manual Install Required:"
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
