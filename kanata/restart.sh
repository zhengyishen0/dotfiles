#!/bin/bash
# Restart Kanata service

echo "Restarting Kanata..."
sudo launchctl bootout system /Library/LaunchDaemons/com.kanata.plist 2>/dev/null || true
sleep 1
sudo launchctl bootstrap system /Library/LaunchDaemons/com.kanata.plist 2>/dev/null || true
sleep 1
echo ""
echo "Status:"
ps aux | grep kanata | grep -v grep
