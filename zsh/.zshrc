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
# Setup & Sync Commands
################################################################################
setup() { source ~/dotfiles/scripts/setup.sh; }
sync-tmux() { ~/dotfiles/scripts/sync-tmux.sh "$@"; }

