#!/bin/bash
# Start Kanata service

sudo launchctl bootstrap system /Library/LaunchDaemons/com.kanata.plist 2>&1 | grep -v "Already loaded" || true
sleep 1
ps aux | grep kanata | grep -v grep
