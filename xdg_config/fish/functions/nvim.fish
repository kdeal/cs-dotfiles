function nvim --wraps nvim
    if not activate -tq
        printf "%sEnvironments available to activate%s\n" (set_color yellow) (set_color normal)
        if confirm "Would you like to activate them"
            activate
        end
    end
    if set -q NVIM
        printf "%sFYI:%s your in nvim\n" (set_color red) (set_color normal)
        if not confirm "Do you want to continue?"
            return 1
        end
    end
    command nvim $argv
end
