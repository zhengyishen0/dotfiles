# Path
export PATH="$PATH:$HOME/.local/bin"

# Completions
if type brew &>/dev/null; then
    FPATH="$(brew --prefix)/share/zsh/site-functions:${FPATH}"
fi
autoload -Uz compinit && compinit
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'
zstyle ':completion:*' menu select
zmodload zsh/complist

# Tools
command -v zoxide &>/dev/null && eval "$(zoxide init zsh)"
command -v fzf &>/dev/null && source <(fzf --zsh)

function y() {
    local tmp="$(mktemp -t "yazi-cwd.XXXXXX")" cwd
    yazi "$@" --cwd-file="$tmp"
    if cwd="$(command cat -- "$tmp")" && [ -n "$cwd" ] && [ "$cwd" != "$PWD" ]; then
        builtin cd -- "$cwd"
    fi
    rm -f -- "$tmp"
}

# Aliases
command -v eza &>/dev/null && alias ls='eza'
command -v bat &>/dev/null && alias cat='bat --paging=never'
command -v dust &>/dev/null && alias du='dust'
command -v duf &>/dev/null && alias df='duf'
command -v procs &>/dev/null && alias ps='procs'

# Dotfiles
setup() { source ~/dotfiles/scripts/setup.sh; }
sync-tmux() { ~/dotfiles/scripts/sync-tmux.sh "$@"; }

# ---- do not edit above this line ----

# Local

# LM Studio
export PATH="$PATH:$HOME/.lmstudio/bin"

# Proxy
proxy_on() {
    export https_proxy=http://127.0.0.1:33210
    export http_proxy=http://127.0.0.1:33210
    echo "Proxy enabled"
}
proxy_off() {
    unset https_proxy http_proxy
    echo "Proxy disabled"
}

# Claude Code
CLAUDE_CODE_DIR="$HOME/Codes/claude-code"

alias claude-ps='pgrep -fl "^claude"'
alias claude-kill='pkill -9 "^claude"'
alias cc="COLUMNS=200 claude --dangerously-skip-permissions"
alias claude-usage="~/.config/opencode/usage.sh"

alias browser="$CLAUDE_CODE_DIR/browser/run.sh"
alias browser-js="node $CLAUDE_CODE_DIR/browser/cli.js"
alias memory="$CLAUDE_CODE_DIR/memory/run.sh"
alias world="$CLAUDE_CODE_DIR/world/run.sh"
alias screenshot="$CLAUDE_CODE_DIR/tools/screenshot/run.sh"
alias proxy="$CLAUDE_CODE_DIR/tools/proxy/run.sh"

[[ -f "$CLAUDE_CODE_DIR/tools/proxy/init.sh" ]] && source "$CLAUDE_CODE_DIR/tools/proxy/init.sh"
