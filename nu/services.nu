# Services management for Kanata and Paneru
# Usage: source this file in config.nu or env.nu

# Kanata - Keyboard remapper
export def "kanata start" [] {
    print "Starting Kanata (requires sudo)..."
    run-external "sudo" "launchctl" "bootstrap" "system" "/Library/LaunchDaemons/com.kanata.plist" e> /dev/null o> /dev/null
    sleep 1sec
    let procs = (^ps aux | complete | get stdout | lines | find kanata | where $it !~ grep)
    if ($procs | is-empty) {
        print "  Warning: Kanata not running (check logs)"
    } else {
        print $procs
    }
}

export def "kanata stop" [] {
    print "Stopping Kanata (requires sudo)..."
    run-external "sudo" "launchctl" "bootout" "system" "/Library/LaunchDaemons/com.kanata.plist" e> /dev/null
    print "Kanata stopped"
}

export def "kanata restart" [] {
    print "Restarting Kanata (requires sudo)..."
    run-external "sudo" "launchctl" "bootout" "system" "/Library/LaunchDaemons/com.kanata.plist" e> /dev/null
    sleep 1sec
    run-external "sudo" "launchctl" "bootstrap" "system" "/Library/LaunchDaemons/com.kanata.plist" e> /dev/null
    sleep 1sec
    print ""
    print "Status:"
    let procs = (^ps aux | complete | get stdout | lines | find kanata | where $it !~ grep)
    if ($procs | is-empty) {
        print "  Not running"
    } else {
        print $procs
    }
}

export def "kanata status" [] {
    print "=== Kanata Status ==="
    print ""
    print "Process:"
    let proc = (^ps aux | rg kanata | rg -v grep | complete)
    if ($proc.stdout | is-empty) {
        print "  Not running"
    } else {
        print $proc.stdout
    }
    print ""
    print "LaunchDaemon:"
    if ("/Library/LaunchDaemons/com.kanata.plist" | path exists) {
        print "  ✓ Installed"
    } else {
        print "  ✗ Not installed"
    }
    print ""
    print "Recent logs:"
    if ("/tmp/kanata.out" | path exists) {
        open /tmp/kanata.out | lines | last 5
    } else {
        print "  No logs"
    }
}

export def "kanata logs" [] {
    if ("/tmp/kanata.out" | path exists) {
        ^tail -f /tmp/kanata.out
    } else {
        print "No Kanata logs found"
    }
}

# Paneru - Window manager
export def "paneru start" [] {
    print "Starting Paneru..."
    ^paneru start
}

export def "paneru stop" [] {
    print "Stopping Paneru..."
    ^paneru stop
}

export def "paneru restart" [] {
    print "Restarting Paneru..."
    ^paneru restart
}

export def "paneru status" [] {
    print "=== Paneru Status ==="
    print ""
    let proc = (^ps aux | rg paneru | rg -v grep | complete)
    if ($proc.stdout | is-empty) {
        print "  Not running"
    } else {
        print $proc.stdout
    }
}

# Karabiner - Keyboard customizer
export def "karabiner start" [] {
    print "Starting Karabiner..."
    let uid = (^id -u | str trim)
    ^launchctl bootstrap $"gui/($uid)" ~/Library/LaunchAgents/org.pqrs.service.agent.karabiner_console_user_server
    sleep 1sec
    ^ps aux | rg karabiner | rg -v grep
}

export def "karabiner stop" [] {
    print "Stopping Karabiner..."
    let uid = (^id -u | str trim)
    ^launchctl bootout $"gui/($uid)/org.pqrs.service.agent.karabiner_console_user_server"
    ^launchctl bootout $"gui/($uid)/org.pqrs.service.agent.Karabiner-NotificationWindow"
    print "Karabiner stopped"
}

export def "karabiner status" [] {
    print "=== Karabiner Status ==="
    print ""
    let proc = (^ps aux | rg karabiner | rg -v grep | complete)
    if ($proc.stdout | is-empty) {
        print "  Not running"
    } else {
        print $proc.stdout
    }
}

# Show all services status
export def "services status" [] {
    kanata status
    print ""
    paneru status
    print ""
    karabiner status
}
