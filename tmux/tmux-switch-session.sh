#!/bin/bash
# Switch to next/prev session sorted by name
direction=$1
current=$(tmux display-message -p '#S')
sessions=$(tmux list-sessions -F '#S' | sort)

if [ "$direction" = "next" ]; then
    target=$(echo "$sessions" | grep -A1 "^${current}$" | tail -1)
    [ "$target" = "$current" ] && target=$(echo "$sessions" | head -1)
else
    target=$(echo "$sessions" | grep -B1 "^${current}$" | head -1)
    [ "$target" = "$current" ] && target=$(echo "$sessions" | tail -1)
fi

tmux switch-client -t "$target"
