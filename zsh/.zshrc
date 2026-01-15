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
    echo "=== System Setup ==="
    echo ""

    # 1. Install Homebrew packages
    echo "[1/4] Installing Homebrew packages..."
    if [[ -f ~/dotfiles/brew/Brewfile ]]; then
        brew bundle install --file=~/dotfiles/brew/Brewfile
    else
        echo "Error: ~/dotfiles/brew/Brewfile not found"
        return 1
    fi
    echo ""

    # 2. GitHub Apps (interactive)
    echo "[2/4] GitHub Apps..."
    echo ""

    # boringNotch
    if [[ ! -d "/Applications/boringNotch.app" ]]; then
        read -p "Install boringNotch from GitHub? [y/N] " -n 1 -r
        echo ""
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            echo "Downloading boringNotch..."
            curl -L "https://github.com/TheBoredTeam/boring.notch/releases/latest/download/boringNotch.dmg" -o /tmp/boringNotch.dmg
            hdiutil attach /tmp/boringNotch.dmg -quiet
            cp -R "/Volumes/boringNotch/boringNotch.app" /Applications/
            hdiutil detach "/Volumes/boringNotch" -quiet
            rm /tmp/boringNotch.dmg
            echo "boringNotch installed!"
        fi
    else
        echo "boringNotch already installed, skipping."
    fi
    echo ""

    # 3. Stow dotfiles
    echo "[3/4] Stowing dotfiles..."
    cd ~/dotfiles
    stow -v zsh git tmux 2>&1 | grep -v "BUG"
    cd - > /dev/null
    echo ""

    # 4. Manual install reminders
    echo "[4/4] Manual Install Required:"
    echo ""
    echo "  Mac App Store:"
    echo "    - Grab2Text"
    echo "    - rcmd"
    echo ""
    echo "  Other:"
    echo "    - Hex, Frost, FreeGecko, Handy, Countdown, Monocle, Affinity"
    echo ""
    echo "  Vimium C:"
    echo "    - Import search engines from: ~/dotfiles/vimium/search-engines.txt"
    echo "    - Import custom keys from:    ~/dotfiles/vimium/custom-keys.txt"
    echo ""

    echo "=== Setup Complete ==="
    echo "Run: source ~/.zshrc"
}

# Update boringNotch from GitHub
update_boringnotch() {
    echo "Updating boringNotch..."
    curl -L "https://github.com/TheBoredTeam/boring.notch/releases/latest/download/boringNotch.dmg" -o /tmp/boringNotch.dmg
    hdiutil attach /tmp/boringNotch.dmg -quiet
    rm -rf "/Applications/boringNotch.app"
    cp -R "/Volumes/boringNotch/boringNotch.app" /Applications/
    hdiutil detach "/Volumes/boringNotch" -quiet
    rm /tmp/boringNotch.dmg
    echo "boringNotch updated!"
}
