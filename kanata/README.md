# Kanata Configuration

Advanced keyboard remapper with tap-hold functionality.

## Installation

Kanata is installed via Homebrew (see `~/dotfiles/brew/Brewfile`):

```bash
brew install kanata
```

## Configuration

- **Config:** `~/dotfiles/kanata/kanata.kbd`
- **Symlink:** `~/.config/kanata/kanata.kbd` → `~/dotfiles/kanata/kanata.kbd`

Changes to the config require restarting Kanata.

### Adjusting Tap-Hold Delay

The tap-hold timeout is controlled by **four variables** at the top of the config:

```lisp
(defvar
  tap-timeout 150      ;; How long to wait to decide it's NOT a tap (shorter = less lag)
  hold-timeout 250     ;; How long to hold to activate hold (longer = less accidental)
  mod-tap-timeout 100  ;; Tap timeout for modifiers (very short = minimal lag)
  mod-hold-timeout 200 ;; Hold timeout for modifiers
)
```

**Understanding the timeouts:**

- **tap-timeout**: Maximum time for a "tap" - if you release faster, it's a tap
  - Shorter = typing feels snappier (less lag)
  - Current: `150ms`
  
- **hold-timeout**: Minimum time to hold before "hold" activates
  - Longer = less accidental triggers
  - Current: `250ms`

- **mod-tap-timeout / mod-hold-timeout**: Same but for modifier keys (Z, C, Caps, ')
  - Shorter = less lag when typing these letters
  - Current: `100ms` / `200ms`

**Current behavior:**
- Type `A` and release within 150ms → outputs `a` (fast!)
- Hold `A` for 250ms → starts outputting `1111...`
- Type `Z` and release within 100ms → outputs `z` (very fast!)
- Hold `Z` for 200ms while pressing another key → Control modifier

**To change:**
1. Edit `~/dotfiles/kanata/kanata.kbd`
2. Adjust the values at the top
3. Restart: `kanata restart` (Nushell) or `~/dotfiles/kanata/restart.sh`

**Recommended adjustments:**

If you feel **lag** (typing feels slow):
```lisp
tap-timeout 100       ;; Even shorter
mod-tap-timeout 80    ;; Very short
```

If you get **accidental triggers** (numbers/symbols appear when typing):
```lisp
hold-timeout 300      ;; Longer
mod-hold-timeout 250  ;; Longer
```

## Key Mappings

All mappings use **300ms tap-hold delay**:
- **Quick tap** (< 300ms) = normal letter
- **Hold** (> 300ms) = number/symbol/modifier

### Caps Lock
- Tap → Escape
- Hold (with another key) → Control

### Top Row (Q-P, ')
- **Q-P** hold → `! @ # $ % ^ & * ( )`
- **'** hold → Right Command

### Home Row (A-;)
- **A-;** hold → `1 2 3 4 5 6 7 8 9 0`

### Bottom Row (Z, C, N, M, ,./\)
- **Z** hold → Control
- **C** hold → Left Option
- **N** hold → `-`
- **M** hold → `=`
- **,** hold → `[`
- **.** hold → `]`
- **/** hold → `\`

## Running Kanata

### Quick Start (Background Service)

**Install the service:**
```bash
~/dotfiles/kanata/install-service.sh
```

**Control the service:**
```bash
~/dotfiles/kanata/start.sh      # Start Kanata
~/dotfiles/kanata/stop.sh       # Stop Kanata
~/dotfiles/kanata/restart.sh    # Restart Kanata
~/dotfiles/kanata/status.sh     # Check status
```

### Manual Commands

**Start/Stop:**
```bash
# Start
sudo launchctl load /Library/LaunchDaemons/com.kanata.plist

# Stop
sudo launchctl unload /Library/LaunchDaemons/com.kanata.plist

# Restart
sudo launchctl unload /Library/LaunchDaemons/com.kanata.plist
sudo launchctl load /Library/LaunchDaemons/com.kanata.plist
```

**Check if running:**
```bash
ps aux | grep kanata
```

### Option: Run in Foreground (Testing)

```bash
# Stop Karabiner first
launchctl bootout gui/$(id -u)/org.pqrs.service.agent.karabiner_console_user_server

# Run Kanata
sudo /opt/homebrew/bin/kanata -c ~/.config/kanata/kanata.kbd
```

Press `Ctrl+C` to stop.

### LaunchDaemon Details

Create `/Library/LaunchDaemons/com.kanata.plist`:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>com.kanata</string>
    <key>ProgramArguments</key>
    <array>
        <string>/opt/homebrew/bin/kanata</string>
        <string>-c</string>
        <string>/Users/YOUR_USERNAME/.config/kanata/kanata.kbd</string>
    </array>
    <key>RunAtLoad</key>
    <true/>
    <key>KeepAlive</key>
    <true/>
    <key>StandardErrorPath</key>
    <string>/tmp/kanata.err</string>
    <key>StandardOutPath</key>
    <string>/tmp/kanata.out</string>
</dict>
</plist>
```

Then:
```bash
sudo launchctl load /Library/LaunchDaemons/com.kanata.plist
```

## Debugging

View logs:
```bash
tail -f /tmp/kanata.out
tail -f /tmp/kanata.err
```

Validate config:
```bash
kanata -c ~/.config/kanata/kanata.kbd --check
```

## Compatibility

**Kanata vs Karabiner-Elements:**
- Cannot run both simultaneously (both grab the keyboard)
- Stop Karabiner before running Kanata
- Choose one based on your needs

## Links

- [Kanata GitHub](https://github.com/jtroo/kanata)
- [Configuration Guide](https://github.com/jtroo/kanata/blob/main/docs/config.adoc)
