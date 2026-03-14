#!/bin/bash
# Stop Kanata service

sudo launchctl bootout system /Library/LaunchDaemons/com.kanata.plist 2>&1 | grep -v "Could not find" || true
echo "Kanata stopped"
