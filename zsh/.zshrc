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

# Claude Code (tools, aliases, proxy)
source "$HOME/Codes/claude-code/env.sh"

# Device-specific settings (not tracked)
[[ -f ~/.zshrc.local ]] && source ~/.zshrc.local
