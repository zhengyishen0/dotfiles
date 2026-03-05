# Ensure essential paths are present (when launched directly, not via zsh)
let EXTRA_PATHS = [
    "/opt/homebrew/bin"
    "/opt/homebrew/sbin"
    ($nu.home-dir | path join ".local/bin")
    ($nu.home-dir | path join ".cargo/bin")
]

$env.PATH = ($env.PATH
    | where {|p| not ($p | str contains ".zenix") }
    | prepend $EXTRA_PATHS
    | uniq)

# oh-my-posh prompt
$env.POSH_THEME = ($nu.home-dir | path join "dotfiles/ohmyposh/config.toml")
source ~/.cache/oh-my-posh/init.nu

# zoxide (z)
source ~/.cache/zoxide/init.nu

# nnn file manager
source ~/dotfiles/nnn/env.nu

$env.EDITOR = "hx"
$env.VISUAL = "hx"

# zenix
source ~/zenix/env.nu
