# Cargo Packages

Rust packages installed via `cargo install`.

## Installation

Cargo packages are automatically installed when running:

```bash
~/dotfiles/scripts/setup.sh
```

## Manual Installation

To install all packages manually:

```bash
while IFS='#' read -r pkg comment; do
    pkg=$(echo "$pkg" | xargs)
    [[ "$pkg" =~ ^#.*$ || -z "$pkg" ]] && continue
    cargo install "$pkg"
done < ~/dotfiles/cargo/packages.txt
```

## Currently Installed

- **felix** - TUI file manager with vim-like keybindings
- **paneru** - Sliding tiling window manager for macOS (config: `~/.paneru`)

## Adding New Packages

Edit `packages.txt` and add a new line:

```
package-name       # Description
```

Then run:
```bash
cargo install package-name
```

Or re-run the setup script.
