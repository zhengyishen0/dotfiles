# Paneru Configuration

Paneru is a sliding, tiling window manager for macOS.

## Installation

Paneru is included in the main dotfiles setup script:

```bash
~/dotfiles/scripts/setup.sh
```

The setup script will:
1. Install paneru via cargo (listed in `~/dotfiles/cargo/packages.txt`)
2. Create the symlink `~/.paneru → ~/dotfiles/paneru/paneru`

### Manual Installation

If you need to install paneru separately:

```bash
# Install via cargo
cargo install paneru

# Symlink is created automatically by setup.sh, or manually:
ln -sf ~/dotfiles/paneru/paneru ~/.paneru

# Install as a background service
paneru install
paneru start
```

See `~/dotfiles/cargo/README.md` for more about managing cargo packages.

## Configuration

The config file is symlinked:
- `~/.paneru` → `~/dotfiles/paneru/paneru`

Changes to the config are automatically reloaded while paneru is running.

## Key Bindings

### Focus Navigation
- `cmd + h/l/k/j` - Move focus left/right/up/down

### Window Swapping
- `alt + h/l/k/j` - Swap windows left/right/up/down

### Jump to Edges
- `cmd + shift + h` - Jump to first window
- `cmd + shift + l` - Jump to last window
- `alt + shift + h` - Move window to first position
- `alt + shift + l` - Move window to last position

### Window Actions
- `alt + c` - Center window
- `alt + r` - Resize (cycles: 33% → 50% → 66% → 100%)
- `alt + f` - Toggle fullwidth
- `alt + t` - Toggle managed/floating
- `alt + ]` - Stack windows
- `alt + shift + ]` - Unstack windows

### Control
- `ctrl + alt + q` - Quit paneru

## Gestures

- **4-finger swipe** (natural direction) - Navigate windows left/right

## Links

- [GitHub](https://github.com/karinushka/paneru)
- [Documentation](https://github.com/karinushka/paneru#readme)
