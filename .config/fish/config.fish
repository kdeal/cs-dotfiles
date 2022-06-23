if status is-interactive
    # Use line when in insert mode
    set -x fish_cursor_insert 'line'
    set -x fish_cursor_expand 'line'

    # Capital raw control chars is for colors only
    set -x LESS '--quit-if-one-screen --RAW-CONTROL-CHARS --no-init'

    # set vi mode
    fish_vi_key_bindings
    fish_user_key_bindings
end
