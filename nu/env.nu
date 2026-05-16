# Ensure essential paths are present (when launched directly, not via zsh)
let EXTRA_PATHS = [
    "/opt/homebrew/bin"
    "/opt/homebrew/sbin"
    ($nu.home-dir | path join ".local/bin")
    ($nu.home-dir | path join ".cargo/bin")
    ($nu.home-dir | path join "go/bin")
    ($nu.home-dir | path join ".orbstack/bin")
]

$env.PATH = ($env.PATH
#     | where {|p| not ($p | str contains ".zenix") }
    | prepend $EXTRA_PATHS
    | uniq)

# oh-my-posh prompt
$env.POSH_THEME = ($nu.home-dir | path join "dotfiles/ohmyposh/config.toml")
source ~/.cache/oh-my-posh/init.nu

# zoxide (zi only, z reserved for zenix)
zoxide init nushell --no-cmd | save -f ~/.cache/zoxide/init.nu
source ~/.cache/zoxide/init.nu
alias zi = __zoxide_zi

# nnn file manager
source ~/dotfiles/nnn/env.nu

$env.EDITOR = "hx"
$env.VISUAL = "hx"

# Homebrew - disable verbose output
$env.HOMEBREW_NO_AUTO_UPDATE = "1"
$env.HOMEBREW_NO_INSTALL_CLEANUP = "1"
$env.HOMEBREW_NO_ENV_HINTS = "1"

source ~/dotfiles/nu/completions-jj.nu

# source ~/Codes/zenix/system/lib/env.nu
