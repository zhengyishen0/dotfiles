# nnn file manager (Tokyo Night theme)
# Order: BLK CHR DIR EXE REG HARDLINK SYMLINK MISSING ORPHAN FIFO SOCK OTHER
# Tokyo Night: blue dirs, green exe, cyan symlink, red orphan
$env.NNN_FCOLORS = "04040407000006000104060e"
$env.NNN_OPTS = "cAa"  # -c (cli opener) -A (no auto-enter) -a (auto FIFO)
$env.NNN_OPENER = ($nu.home-dir | path join ".config/nnn/opener")
$env.NNN_FIFO = "/tmp/nnn.fifo"  # for preview-tui
$env.NNN_PLUG = "j:autojump;v:preview-tui;f:fzopen;o:openfinder"  # ;j = zoxide, ;v = preview, ;f = fzf file, ;o = Finder

# Kitty terminal integration (for preview-tui)
if "KITTY_PID" in $env {
    $env.KITTY_LISTEN_ON = $"unix:/tmp/mykitty"
}
