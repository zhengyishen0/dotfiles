#!/usr/bin/env nu

# Restart swiped daemon
def main [] {
    launchctl kickstart -k gui/501/com.swiped
    print "swiped restarted"
}

main
