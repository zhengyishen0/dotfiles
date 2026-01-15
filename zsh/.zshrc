################################################################################
# Environment Variables
################################################################################
export PATH="$PATH:$HOME/.local/bin"

# Context7 API key
export CONTEXT7_API_KEY='ctx7sk-ab0ddc96-7d9f-4a62-8c0f-0fd3f7d1adcb'

# LM Studio CLI
export PATH="$PATH:$HOME/.lmstudio/bin"


################################################################################
# Claude Code
################################################################################
CLAUDE_CODE_DIR="$HOME/Codes/claude-code"

# Process management
alias claude-ps='pgrep -fl "^claude"'
alias claude-kill='pkill -9 "^claude"'

# Direct tool aliases (root-level tools)
alias browser="$CLAUDE_CODE_DIR/browser/run.sh"
alias browser-js="node $CLAUDE_CODE_DIR/browser/cli.js"
alias memory="$CLAUDE_CODE_DIR/memory/run.sh"
alias world="$CLAUDE_CODE_DIR/world/run.sh"

# Tools in tools/
alias screenshot="$CLAUDE_CODE_DIR/tools/screenshot/run.sh"
alias proxy="$CLAUDE_CODE_DIR/tools/proxy/run.sh"

# Claude Code CLI
alias cc="COLUMNS=200 claude --dangerously-skip-permissions"

# Usage tracking
alias claude-usage="~/.config/opencode/usage.sh"

# Proxy auto-enable
[[ -f "$CLAUDE_CODE_DIR/tools/proxy/init.sh" ]] && source "$CLAUDE_CODE_DIR/tools/proxy/init.sh"


################################################################################
# Proxy Configuration
################################################################################
proxy_on() {
    export https_proxy=http://127.0.0.1:33210
    export http_proxy=http://127.0.0.1:33210
    echo "Proxy enabled"
}

proxy_off() {
    unset https_proxy http_proxy
    echo "Proxy disabled"
}


################################################################################
# Tool Initialization (order matters)
################################################################################
# Homebrew completions (must be before compinit)
if type brew &>/dev/null; then
    FPATH="$(brew --prefix)/share/zsh/site-functions:${FPATH}"
fi

# Completion system
autoload -Uz compinit && compinit

# Case-insensitive completion
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'

# Menu selection
zstyle ':completion:*' menu select
zmodload zsh/complist

# zoxide - smart cd
if command -v zoxide &>/dev/null; then
    eval "$(zoxide init zsh)"
fi

# fzf - fuzzy finder
if command -v fzf &>/dev/null; then
    source <(fzf --zsh)
fi

# yazi - file manager with cd on exit
function y() {
    local tmp="$(mktemp -t "yazi-cwd.XXXXXX")" cwd
    yazi "$@" --cwd-file="$tmp"
    if cwd="$(command cat -- "$tmp")" && [ -n "$cwd" ] && [ "$cwd" != "$PWD" ]; then
        builtin cd -- "$cwd"
    fi
    rm -f -- "$tmp"
}


################################################################################
# Modern CLI Aliases
################################################################################
# Only set if commands exist
command -v eza &>/dev/null && alias ls='eza'
command -v bat &>/dev/null && alias cat='bat --paging=never'
command -v dust &>/dev/null && alias du='dust'
command -v duf &>/dev/null && alias df='duf'
command -v procs &>/dev/null && alias ps='procs'


################################################################################
# Setup Function
################################################################################
setup() {
    local DOTFILES=~/dotfiles
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
        return 1
    fi
    echo ""

    # 3. GitHub Apps (interactive) - read from apps/github.txt
    echo "[3/5] GitHub Apps..."
    if [[ -f $DOTFILES/apps/github.txt ]]; then
        while IFS='|' read -r name app_path dmg_url volume_name; do
            [[ "$name" =~ ^#.*$ || -z "$name" ]] && continue  # skip comments and empty lines
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
    stow -v zsh git tmux 2>&1 | grep -v "BUG"
    cd - > /dev/null
    echo ""

    # 5. Manual install reminders - read from apps/manual.txt
    echo "[5/5] Manual Install Required:"
    echo ""
    if [[ -f $DOTFILES/apps/manual.txt ]]; then
        local mas_apps=()
        local other_apps=()
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
}

