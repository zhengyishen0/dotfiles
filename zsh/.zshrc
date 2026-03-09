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
command -v oh-my-posh &>/dev/null && eval "$(oh-my-posh init zsh --config ~/dotfiles/ohmyposh/config.toml)"

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

# Device-specific settings (not tracked)
[[ -f ~/.zshrc.local ]] && source ~/.zshrc.local

# Opt+Arrow word navigation (CSI sequences from Ghostty)
bindkey '\e[1;3D' backward-word  # Opt+Left
bindkey '\e[1;3C' forward-word   # Opt+Right
bindkey '\e[H' beginning-of-line  # Cmd+Left (Home)
bindkey '\e[F' end-of-line        # Cmd+Right (End)

# Cmd+Z (CSI u sequence from Ghostty)
bindkey '\e[122;9u' undo  # Cmd+Z
export CLOUDSDK_PYTHON=/opt/homebrew/bin/python3.14

# Google Cloud SDK
export PATH="$HOME/google-cloud-sdk/bin:$PATH"
source "$HOME/google-cloud-sdk/completion.zsh.inc"

# zenix
source "/Users/zhengyishen/Codes/claude-code/env"

# Added by LM Studio CLI (lms)
export PATH="$PATH:/Users/zhengyishen/.lmstudio/bin"
# End of LM Studio CLI section

export PATH="$HOME/.config/emacs/bin:$PATH"

source /Users/zhengyishen/.config/broot/launcher/bash/br
