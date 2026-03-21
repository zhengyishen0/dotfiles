# nnn file manager configuration

# Tokyo Night theme colors
set -gx NNN_FCOLORS "04040407000006000104060e"

# Options: c=cli-only opener, A=no auto-enter, a=auto NNN_FIFO
set -gx NNN_OPTS "cAa"
set -gx NNN_PAGER "cat"
set -gx NNN_OPENER "$HOME/.config/nnn/opener"
set -gx NNN_FIFO "/tmp/nnn.fifo"
set -gx NNN_PLUG "v:preview-tui;j:autojump;f:fzopen;o:openfinder;d:duplicate"

# nnn with auto-preview and cd on quit
function n
    set -l NNN_TMPFILE "$HOME/.config/nnn/.lastd"
    NNN_TMPFILE=$NNN_TMPFILE nnn -P v $argv
    if test -f $NNN_TMPFILE
        source $NNN_TMPFILE
        rm -f $NNN_TMPFILE
    end
end
