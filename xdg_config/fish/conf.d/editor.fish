if command -qs nvim
    set -x EDITOR (command -s nvim)
    # Use neovim as man page viewer
    set -x MANPAGER "nvim +Man!"
else
    set -x EDITOR (command -s vim)
end

set -x VISUAL $EDITOR
