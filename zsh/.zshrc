# Path
export PATH="$PATH:$HOME/.local/bin"

# macOS app CLIs (wrapper scripts in ~/.local/bin, created by setup script)
if [[ ! -x ~/.local/bin/tailscale ]] && [[ -x /Applications/Tailscale.app/Contents/MacOS/Tailscale ]]; then
    mkdir -p ~/.local/bin
    printf '#!/bin/bash\n/Applications/Tailscale.app/Contents/MacOS/Tailscale "$@"\n' > ~/.local/bin/tailscale
    chmod +x ~/.local/bin/tailscale
fi

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
command -v starship &>/dev/null && eval "$(starship init zsh)"

function y() {
    local tmp="$(mktemp -t "yazi-cwd.XXXXXX")" cwd
    yazi "$@" --cwd-file="$tmp"
    if cwd="$(command cat -- "$tmp")" && [ -n "$cwd" ] && [ "$cwd" != "$PWD" ]; then
        builtin cd -- "$cwd"
    fi
    rm -f -- "$tmp"
}

# Zsh plugins
source /opt/homebrew/share/zsh-autopair/autopair.zsh
source /opt/homebrew/share/zsh-autosuggestions/zsh-autosuggestions.zsh
source /opt/homebrew/share/zsh-history-substring-search/zsh-history-substring-search.zsh
source /opt/homebrew/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
bindkey '^[[A' history-substring-search-up
bindkey '^[[B' history-substring-search-down

# Aliases
command -v eza &>/dev/null && alias ls='eza'
command -v bat &>/dev/null && alias cat='bat --paging=never'
command -v dust &>/dev/null && alias du='dust'
command -v duf &>/dev/null && alias df='duf'
command -v procs &>/dev/null && alias ps='procs'
# Dotfiles
sync-tmux() { ~/dotfiles/scripts/sync-tmux.sh "$@"; }

# Ghostty
alias ghostty='~/dotfiles/scripts/ghostty.sh'

ghostty-kill() {
    local current=$(tty | sed 's|/dev/||')
    if [[ -n "$1" ]]; then
        pkill -t "$1"  # kill specific: ghostty-kill ttys031
    else
        # kill all except current
        ghostty-sessions | grep -v "$current" | xargs -I{} pkill -t {}
    fi
}

# WezTerm + zmx: session managed by WezTerm config, not shell

# Device-specific settings (not tracked)
[[ -f ~/.zshrc.local ]] && source ~/.zshrc.local
