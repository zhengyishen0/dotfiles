# Fish Configuration
# ------------------
# This file is symlinked from ~/dotfiles/fish/config.fish to ~/.config/fish/config.fish

# Environment Variables
# ---------------------
if test -x /opt/homebrew/bin/brew
    # Only set PATH, skip analytics/auto-update
    set -gx HOMEBREW_PREFIX /opt/homebrew
    set -gx HOMEBREW_CELLAR /opt/homebrew/Cellar
    set -gx HOMEBREW_REPOSITORY /opt/homebrew
    set -gx HOMEBREW_NO_INSTALL_FROM_API 1
    set -gx HOMEBREW_NO_AUTO_UPDATE 1
    set -gx PATH /opt/homebrew/bin /opt/homebrew/sbin $PATH
end
set -gx PATH $HOME/.bun/bin $HOME/.local/bin $PATH $HOME/google-cloud-sdk/bin $HOME/.config/emacs/bin /Users/zhengyishen/.lmstudio/bin
set -gx EDITOR hx

# Prompt & Shell Tools
# --------------------
# oh-my-posh (uses ~/dotfiles/ohmyposh/config.toml)
if command -v oh-my-posh > /dev/null
    oh-my-posh init fish --config ~/dotfiles/ohmyposh/config.toml | source
end

# zoxide (cd override, zi for interactive)
if command -v zoxide > /dev/null
    zoxide init fish --cmd cd | source
end

# fzf
if command -v fzf > /dev/null
    fzf --fish | source
end

# Aliases
# -------
if command -v eza > /dev/null
    alias ls='eza'
end

if command -v bat > /dev/null
    alias cat='bat --paging=never'
end

if command -v dust > /dev/null
    alias du='dust'
end

if command -v duf > /dev/null
    alias df='duf'
end

if command -v procs > /dev/null
    alias ps='procs'
end


# Navigation Functions
# --------------------
function y
    set -l tmp (mktemp -t "yazi-cwd.XXXXXX")
    yazi $argv --cwd-file="$tmp"
    if set -l cwd (command cat -- "$tmp"); and [ -n "$cwd" ]; and [ "$cwd" != "$PWD" ]
        builtin cd -- "$cwd"
    end
    rm -f -- "$tmp"
end

function fx
    set -l runtime_dir (test -n "$TMPDIR" && echo "$TMPDIR/felix" || echo "/tmp/felix")
    mkdir -p $runtime_dir
    SHELL_PID=$fish_pid ~/.cargo/bin/fx $argv
    set -l lwd_file "$runtime_dir/$fish_pid"
    if test -f $lwd_file
        builtin cd (command cat $lwd_file)
        rm -f $lwd_file
    end
end



# Key Bindings
# ------------
function fish_user_key_bindings
    # Opt+Left/Right (based on Ghostty/WezTerm CSI sequences)
    bind \e\[1\;3D backward-word
    bind \e\[1\;3C forward-word
    
    # Cmd+Left/Right (Home/End)
    bind \e\[H beginning-of-line
    bind \e\[F end-of-line
    
    # Cmd+Z (Undo)
    bind \e\[122\;9u undo
end

# Load local overrides
if test -f ~/.config/fish/config.fish.local
    source ~/.config/fish/config.fish.local
end

# >>> conda initialize >>>
# !! Contents within this block are managed by 'conda init' !!
if test -f /opt/anaconda3/bin/conda
    eval /opt/anaconda3/bin/conda "shell.fish" "hook" $argv | source
else
    if test -f "/opt/anaconda3/etc/fish/conf.d/conda.fish"
        . "/opt/anaconda3/etc/fish/conf.d/conda.fish"
    else
        set -x PATH "/opt/anaconda3/bin" $PATH
    end
end
# <<< conda initialize <<<

