#!/bin/bash
# Equalize column widths without affecting vertical stacks within columns

window_width=$(tmux display-message -p '#{window_width}')
column_lefts=$(tmux list-panes -F '#{pane_left}' | sort -n | uniq)
num_columns=$(echo "$column_lefts" | wc -l | tr -d ' ')

[ "$num_columns" -le 1 ] && exit 0

# Target width per column (accounting for 1-char borders)
target_width=$(( (window_width - num_columns + 1) / num_columns ))

# Resize one pane per column
for col_left in $column_lefts; do
    pane_id=$(tmux list-panes -F '#{pane_id} #{pane_left}' | awk -v l="$col_left" '$2==l {print $1; exit}')
    [ -n "$pane_id" ] && tmux resize-pane -t "$pane_id" -x "$target_width" 2>/dev/null
done
