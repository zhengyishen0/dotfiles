#!/bin/bash
# Check Kanata status

echo "=== Kanata Status ==="
echo ""
echo "Process:"
ps aux | grep kanata | grep -v grep || echo "  Not running"
echo ""
echo "LaunchDaemon:"
if [[ -f /Library/LaunchDaemons/com.kanata.plist ]]; then
    echo "  Installed: /Library/LaunchDaemons/com.kanata.plist"
else
    echo "  Not installed"
fi
echo ""
echo "Recent logs (last 5 lines):"
tail -5 /tmp/kanata.out 2>/dev/null || echo "  No logs"
