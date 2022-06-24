function fish_user_key_bindings
    for mode in normal insert
        bind --mode $mode \cg nextd-or-forward-word
        bind --mode $mode \cf forward-char
    end

    fzf_key_bindings
end
