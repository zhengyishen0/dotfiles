# Nushell Services Management

Convenient commands to manage Kanata, Paneru, and Karabiner from Nushell.

## Installation

The services module is automatically loaded in `config.nu`:

```nu
use ~/dotfiles/nu/services.nu *
```

## Available Commands

### Kanata (Keyboard Remapper)

```nu
kanata start      # Start Kanata service (requires sudo password)
kanata stop       # Stop Kanata service (requires sudo password)
kanata restart    # Restart Kanata service (requires sudo password)
kanata status     # Show Kanata status and logs
kanata logs       # Tail Kanata logs in real-time
```

**Note:** Kanata commands require sudo and will prompt for your password.

### Paneru (Window Manager)

```nu
paneru start      # Start Paneru service
paneru stop       # Stop Paneru service
paneru restart    # Restart Paneru service
paneru status     # Show Paneru status
```

### Karabiner-Elements

```nu
karabiner start   # Start Karabiner services
karabiner stop    # Stop Karabiner services
karabiner status  # Show Karabiner status
```

### All Services

```nu
services status   # Show status of all services
```

## Usage Examples

```nu
# Start Kanata
kanata start

# Check if it's running
kanata status

# View live logs
kanata logs

# Restart after config change
kanata restart

# Stop Kanata and start Karabiner instead
kanata stop
karabiner start

# Check everything
services status
```

## Notes

- **Kanata** requires sudo (will prompt for password)
- **Paneru** uses its built-in service management
- **Karabiner** can run alongside Paneru, but conflicts with Kanata
- Use `kanata stop` before starting Karabiner (they can't run together)
