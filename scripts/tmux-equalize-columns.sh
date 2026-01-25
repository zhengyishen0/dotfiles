#!/bin/bash
# Equalize column widths without affecting vertical stacks

window_width=$(tmux display-message -p '#{window_width}')

# Get unique column left positions (sorted numerically)
cols=($(tmux list-panes -F '#{pane_left}' | sort -nu))
num_cols=${#cols[@]}

[ "$num_cols" -le 1 ] && exit 0

# Calculate target width (window_width - borders) / num_cols
# Borders: 1 char between each column = num_cols - 1
usable=$((window_width - num_cols + 1))
target=$((usable / num_cols))

# Resize columns left to right, except last (gets remaining space)
for ((i = 0; i < num_cols - 1; i++)); do
    col_left=${cols[$i]}
    # Get first pane at this column position
    pane=$(tmux list-panes -F '#{pane_id} #{pane_left}' | awk -v l="$col_left" '$2 == l {print $1; exit}')
    [ -n "$pane" ] && tmux resize-pane -t "$pane" -x "$target" 2>/dev/null
done
