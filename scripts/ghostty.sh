#!/bin/bash
# Ghostty session management

ghostty_pid() {
    /bin/ps -eo pid,comm | grep -E 'ghostty$' | awk '{print $1}'
}

ghostty_list() {
    local gpid=$(ghostty_pid)
    [[ -z "$gpid" ]] && echo "Ghostty not running" && return 1

    echo "TTY         STATE   CWD                              RUNNING"
    echo "---         -----   ---                              -------"
    for tty in $(/bin/ps -eo pid,ppid,tty,comm | awk -v g="$gpid" '$2 == g {print $3}'); do
        local shell_pid=$(/bin/ps -eo pid,tty,comm | grep "^[[:space:]]*[0-9]* $tty" | grep zsh | awk '{print $1}' | head -1)
        local cwd=""
        [[ -n "$shell_pid" ]] && cwd=$(lsof -p "$shell_pid" 2>/dev/null | grep cwd | awk '{print $NF}' | sed "s|$HOME|~|")

        local leaf=$(/bin/ps -eo tty,stat,comm | grep "^$tty" | grep -v "login\|zsh" | tail -1 | awk '{print $2, $3}')
        if [[ -z "$leaf" ]]; then
            printf "%-11s %-7s %-32s %s\n" "$tty" "idle" "${cwd:--}" "(zsh)"
        else
            local stat=$(echo $leaf | awk '{print $1}')
            local cmd=$(echo $leaf | awk '{print $2}')
            local state=$([[ "$stat" == *"+"* ]] && echo "active" || echo "bg")
            printf "%-11s %-7s %-32s %s\n" "$tty" "$state" "${cwd:--}" "$cmd"
        fi
    done
}

ghostty_kill() {
    local current=$(tty 2>/dev/null | sed 's|/dev/||')
    if [[ -n "$1" ]]; then
        pkill -t "$1"
    else
        echo "Usage: ghostty kill <tty>      # kill specific session"
        echo "       ghostty kill --idle     # kill all idle sessions"
        echo "       ghostty kill --all      # kill all except current"
        return 1
    fi

    if [[ "$1" == "--idle" ]]; then
        local gpid=$(ghostty_pid)
        for tty in $(/bin/ps -eo pid,ppid,tty,comm | awk -v g="$gpid" '$2 == g {print $3}'); do
            [[ "$tty" == "$current" ]] && continue
            local leaf=$(/bin/ps -eo tty,stat,comm | grep "^$tty" | grep -v "login\|zsh" | tail -1)
            [[ -z "$leaf" ]] && pkill -t "$tty" && echo "Killed $tty"
        done
    elif [[ "$1" == "--all" ]]; then
        local gpid=$(ghostty_pid)
        for tty in $(/bin/ps -eo pid,ppid,tty,comm | awk -v g="$gpid" '$2 == g {print $3}'); do
            [[ "$tty" != "$current" ]] && pkill -t "$tty" && echo "Killed $tty"
        done
    else
        pkill -t "$1" && echo "Killed $1"
    fi
}

case "$1" in
    list|ls|l) ghostty_list ;;
    kill|k) shift; ghostty_kill "$@" ;;
    *)
        echo "Usage: ghostty <command>"
        echo ""
        echo "Commands:"
        echo "  list, ls, l    List all sessions"
        echo "  kill, k <tty>  Kill specific session"
        echo "  kill --idle    Kill all idle sessions"
        echo "  kill --all     Kill all except current"
        ;;
esac
