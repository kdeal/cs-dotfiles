function expand-execute -d 'Executes word expansion on the current token'
    # Iterate available expansions for one that matches the current token.
    for expansion in $__expand_expanders
        set expansion (echo $expansion)

        # Check if the expansion condition matches the token.
        if eval "$expansion[1]" >/dev/null
            if [ -n "$expansion[3]" ]
                set preview "--preview=$expansion[3]"
            else
                set preview ""
            end
            set replacement (fish -c "$expansion[2]" | sed '/^\s*$/d' | fzf --ansi --select-1 $preview)
            set replacement (echo $replacement | fish -c "$expansion[4]")
            break
        end
    end

    # Interactive filters will cause Fish to need a repaint.
    commandline -f repaint

    # If a replacement was chosen, use it.
    if [ -n "$replacement" ]
        commandline -t -r "$replacement"
    end
end
