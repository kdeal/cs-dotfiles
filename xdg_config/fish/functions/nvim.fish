function nvim --wraps nvim
    if not activate -tq
        printf "%sEnvironments available to activate%s\n" (set_color yellow) (set_color normal)
        if confirm "Would you like to activate them"
            activate
        end
    end
    command nvim $argv
end
