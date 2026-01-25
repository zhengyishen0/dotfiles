#!/bin/bash
# Equalize column widths

equalize() {
    local window_width=$(tmux display-message -p '#{window_width}')
    local cols=($(tmux list-panes -F '#{pane_left}' | sort -nu))
    local num_cols=${#cols[@]}
    
    [ "$num_cols" -le 1 ] && return
    
    local usable=$((window_width - num_cols + 1))
    local target=$((usable / num_cols))
    
    # Resize each column except last, re-reading positions each time
    for ((i = 0; i < num_cols - 1; i++)); do
        cols=($(tmux list-panes -F '#{pane_left}' | sort -nu))
        local col_left=${cols[$i]}
        local pane=$(tmux list-panes -F '#{pane_id} #{pane_left}' | awk -v l="$col_left" '$2 == l {print $1; exit}')
        [ -n "$pane" ] && tmux resize-pane -t "$pane" -x "$target" 2>/dev/null
    done
}

# Run multiple times to converge
equalize
equalize
equalize
