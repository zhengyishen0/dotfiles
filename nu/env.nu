# Remove old zenix PATH (inherited from zsh)
$env.PATH = ($env.PATH | where {|p| not ($p | str contains ".zenix") })

# oh-my-posh prompt
source ~/.cache/oh-my-posh/init.nu

# zenix
source ~/zenix/env.nu
