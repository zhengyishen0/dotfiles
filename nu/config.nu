# config.nu
#
# This file is used to override default Nushell settings, define
# (or import) custom commands, or run any other startup tasks.
# See https://www.nushell.sh/book/configuration.html
#
# Nushell sets "sensible defaults" for most configuration settings,
# so your `config.nu` only needs to override these defaults if desired.
#
# You can open this file in your default editor using:
#     config nu
#
# You can also pretty-print and page through the documentation for configuration
# options using:
#     config nu --doc | nu-highlight | less -R

$env.config.show_banner = false

# Services management (Kanata, Paneru, Karabiner)
use ~/dotfiles/nu/services.nu *

# nnn with cd on quit (Ctrl+G) and auto-preview
def --env n [...args] {
    let tmp = $"/tmp/nnn-cd-($nu.pid)"
    $env.NNN_TMPFILE = $tmp
    ^nnn -P v ...$args
    if ($tmp | path exists) {
        let content = (open $tmp | str trim)
        rm $tmp
        # nnn writes "cd '/path'" - strip "cd '" prefix and "'" suffix
        let target = ($content | str replace "cd '" "" | str replace "'" "")
        if ($target | is-not-empty) {
            cd $target
        }
    }
}

# broot with cd on quit
def --env br [...args] {
    let cmd_file = $"/tmp/broot-($nu.pid).tmp"
    touch $cmd_file
    ^broot --outcmd $cmd_file ...$args
    let cmd = (open $cmd_file | str trim)
    rm -f $cmd_file
    if ($cmd | is-not-empty) {
        let target = ($cmd | parse -r `^cd\s+["']?(?<path>.+?)["']?$` | get 0?.path?)
        if ($target | is-not-empty) {
            cd $target
        }
    }
}

use '/Users/zhengyishen/.config/broot/launcher/nushell/br' *
