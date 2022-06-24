if status is-interactive
    # Use line when in insert mode
    set fish_cursor_insert 'line'

    # Capital raw control chars is for colors only
    set -x LESS '--quit-if-one-screen --RAW-CONTROL-CHARS --no-init'

    # set vi mode
    fish_vi_key_bindings
end
