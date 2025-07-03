function fish_user_key_bindings
    for mode in normal insert
        bind --mode $mode \cg nextd-or-forward-word
        bind --mode $mode \cf forward-char
    end

    for mode in normal insert visual
        bind --mode $mode \cn expand-execute
        bind --mode $mode \cp expand-execute
    end
end

fzf --fish | source
