# Ensure essential paths are present (when launched directly, not via zsh)
const EXTRA_PATHS = [
    "/opt/homebrew/bin"
    "/opt/homebrew/sbin"
    ($nu.home-path | path join ".local/bin")
]

$env.PATH = ($env.PATH
    | where {|p| not ($p | str contains ".zenix") }
    | prepend $EXTRA_PATHS
    | uniq)

# oh-my-posh prompt
source ~/.cache/oh-my-posh/init.nu

# zenix
source ~/zenix/env.nu
