# ==============================================================================
# PATH & BREW (hardcoded, no subprocess)
# ==============================================================================
export HOMEBREW_PREFIX="/opt/homebrew"
export HOMEBREW_CELLAR="/opt/homebrew/Cellar"
export HOMEBREW_REPOSITORY="/opt/homebrew"
export PATH="$HOME/.local/bin:$HOME/bin:$HOMEBREW_PREFIX/bin:$HOMEBREW_PREFIX/sbin:$PATH"
export MANPATH=":${MANPATH#:}"
export INFOPATH="$HOMEBREW_PREFIX/share/info:${INFOPATH:-}"
FPATH="$HOMEBREW_PREFIX/share/zsh/site-functions:${FPATH}"

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
# oh-my-posh (cached)
_omp_cache="$HOME/.cache/oh-my-posh-init.zsh"
if [[ ! -f "$_omp_cache" ]] || [[ ~/dotfiles/ohmyposh/config.toml -nt "$_omp_cache" ]]; then
    mkdir -p "$HOME/.cache"
    oh-my-posh init zsh --config ~/dotfiles/ohmyposh/config.toml > "$_omp_cache"
fi
source "$_omp_cache"

# zoxide (cached)
_zoxide_cache="$HOME/.cache/zoxide-init.zsh"
if [[ ! -f "$_zoxide_cache" ]]; then
    zoxide init zsh --no-cmd > "$_zoxide_cache"
fi
source "$_zoxide_cache"
alias zi='__zoxide_zi'

# fzf (cached)
_fzf_cache="$HOME/.cache/fzf-init.zsh"
if [[ ! -f "$_fzf_cache" ]]; then
    fzf --zsh > "$_fzf_cache"
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
alias xx="claude --dangerously-skip-permissions"
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
