# ==============================================================================
# PATH & BREW (hardcoded, no subprocess)
# ==============================================================================
export HOMEBREW_PREFIX="/opt/homebrew"
export HOMEBREW_CELLAR="/opt/homebrew/Cellar"
export HOMEBREW_REPOSITORY="/opt/homebrew"
export PATH="$HOME/.local/bin:$HOME/bin:$HOMEBREW_PREFIX/bin:$HOMEBREW_PREFIX/sbin:$PATH"
export MANPATH=":${MANPATH#:}"
export INFOPATH="$HOMEBREW_PREFIX/share/info:${INFOPATH:-}"
export HOMEBREW_NO_AUTO_UPDATE=1
export HOMEBREW_NO_BOTTLE_SOURCE_FALLBACK=1
export HOMEBREW_CLEANUP_MAX_AGE_DAYS=0
FPATH="$HOMEBREW_PREFIX/share/zsh/site-functions:${FPATH}"

# Default editor: Helix (used by zellij Strider/scrollback/edit, git, etc.)
export EDITOR=hx
export VISUAL=hx

# ==============================================================================
# COMPLETIONS (cached, rebuilds daily)
# ==============================================================================
autoload -Uz compinit
if [[ -z "$ZSH_COMPDUMP" ]]; then
    ZSH_COMPDUMP="${ZDOTDIR:-$HOME}/.zcompdump"
fi
if [[ "$ZSH_COMPDUMP"(#qNmh+24) ]]; then
    compinit -d "$ZSH_COMPDUMP"
else
    compinit -C -d "$ZSH_COMPDUMP"
fi
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'
zstyle ':completion:*' menu select
zmodload zsh/complist

# ==============================================================================
# TOOLS (cached init where possible)
# ==============================================================================
# oh-my-posh: don't cache. `init` output embeds a fresh POSH_SESSION_ID tied
# to ~/.cache/oh-my-posh/omp.cache, which rotates. A cached stub eventually
# points at an evicted entry, so the config path can't be resolved and
# oh-my-posh falls back to the default theme. Running init live is ~11ms.
eval "$(oh-my-posh init zsh --config ~/dotfiles/ohmyposh/config.toml)"

# zoxide (cached)
_zoxide_cache="$HOME/.cache/zoxide-init.zsh"
if [[ ! -f "$_zoxide_cache" ]]; then
    zoxide init zsh --no-cmd > "$_zoxide_cache"
fi
source "$_zoxide_cache"
alias z='__zoxide_z'
alias zi='__zoxide_zi'

# fzf (cached)
# Patch: fzf --zsh saves/restores all shell options via eval, including the
# read-only `zle` state, which throws `can't change option: zle`. Silence just
# those two restore evals.
_fzf_cache="$HOME/.cache/fzf-init.zsh"
if [[ ! -f "$_fzf_cache" ]]; then
    fzf --zsh | sed -E 's/^([[:space:]]*eval \$__fzf_(key_bindings|completion)_options)$/\1 2>\/dev\/null/' > "$_fzf_cache"
fi
source "$_fzf_cache"

# yazi wrapper
function y() {
    local tmp="$(mktemp -t "yazi-cwd.XXXXXX")" cwd
    yazi "$@" --cwd-file="$tmp"
    if cwd="$(command cat -- "$tmp")" && [ -n "$cwd" ] && [ "$cwd" != "$PWD" ]; then
        builtin cd -- "$cwd"
    fi
    rm -f -- "$tmp"
}

# ==============================================================================
# ZSH PLUGINS
# ==============================================================================
source $HOMEBREW_PREFIX/share/zsh-autopair/autopair.zsh
source $HOMEBREW_PREFIX/share/zsh-autosuggestions/zsh-autosuggestions.zsh
source $HOMEBREW_PREFIX/share/zsh-history-substring-search/zsh-history-substring-search.zsh
source $HOMEBREW_PREFIX/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
bindkey '^[[A' history-substring-search-up
bindkey '^[[B' history-substring-search-down

# ==============================================================================
# ALIASES
# ==============================================================================
command -v eza &>/dev/null && alias ls='eza'
command -v bat &>/dev/null && alias cat='bat --paging=never'
command -v dust &>/dev/null && alias du='dust'
command -v duf &>/dev/null && alias df='duf'
command -v procs &>/dev/null && alias ps='procs'
alias cc="claude --dangerously-skip-permissions"
sync-tmux() { ~/dotfiles/scripts/sync-tmux.sh "$@"; }

# ==============================================================================
# KEY BINDINGS
# ==============================================================================
bindkey '\e[1;3D' backward-word   # Opt+Left
bindkey '\e[1;3C' forward-word    # Opt+Right
bindkey '\e[H' beginning-of-line  # Cmd+Left (Home)
bindkey '\e[F' end-of-line        # Cmd+Right (End)
bindkey '\e[122;9u' undo          # Cmd+Z

# ==============================================================================
# LOCAL OVERRIDES (not tracked, secrets & machine-specific go here)
# ==============================================================================
[[ -f ~/.zshrc.local ]] && source ~/.zshrc.local
alias yp='ssh -t youpu /home/ubuntu/.local/bin/zellij attach -c main'
