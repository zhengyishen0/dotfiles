#!/bin/bash
# Install Kanata as a LaunchDaemon (background service)

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PLIST_SOURCE="$SCRIPT_DIR/com.kanata.plist"
PLIST_PATH="/Library/LaunchDaemons/com.kanata.plist"
KANATA_BIN="/opt/homebrew/bin/kanata"
KANATA_CONFIG="$HOME/.config/kanata/kanata.kbd"
USERNAME=$(whoami)

echo "=== Kanata LaunchDaemon Setup ==="
echo ""

# Check if kanata is installed
if [[ ! -f "$KANATA_BIN" ]]; then
    echo "Error: Kanata not found at $KANATA_BIN"
    echo "Install with: brew install kanata"
    exit 1
fi

# Check if config exists
if [[ ! -f "$KANATA_CONFIG" ]]; then
    echo "Error: Config not found at $KANATA_CONFIG"
    exit 1
fi

# Check if plist source exists
if [[ ! -f "$PLIST_SOURCE" ]]; then
    echo "Error: Plist source not found at $PLIST_SOURCE"
    exit 1
fi

# Check if already installed
if [[ -f "$PLIST_PATH" ]]; then
    echo "Kanata LaunchDaemon already installed."
    read -p "Reinstall? [y/N] " -n 1 -r
    echo ""
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "Aborted."
        exit 0
    fi
    echo "Unloading existing service..."
    sudo launchctl bootout system "$PLIST_PATH" 2>/dev/null || true
    sudo rm "$PLIST_PATH"
fi

# Copy plist to system location
echo "Installing LaunchDaemon plist..."
sudo cp "$PLIST_SOURCE" "$PLIST_PATH"
sudo chown root:wheel "$PLIST_PATH"
sudo chmod 644 "$PLIST_PATH"

# Load service
echo "Loading Kanata service..."
sudo launchctl bootstrap system "$PLIST_PATH"

sleep 2

echo ""
echo "=== Kanata Service Installed ==="
echo ""
echo "Status:"
ps aux | grep kanata | grep -v grep || echo "  Not running (check logs)"
echo ""
echo "Logs:"
echo "  tail -f /tmp/kanata.out"
echo "  tail -f /tmp/kanata.err"
echo ""
echo "Control:"
echo "  Start:   kanata start"
echo "  Stop:    kanata stop"
echo "  Restart: kanata restart"
echo "  Status:  kanata status"
echo "  Logs:    kanata logs"
echo ""
echo "Uninstall:"
echo "  sudo launchctl bootout system $PLIST_PATH"
echo "  sudo rm $PLIST_PATH"
