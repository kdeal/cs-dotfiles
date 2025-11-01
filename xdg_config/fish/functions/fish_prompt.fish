function fish_prompt --description 'Write out the prompt'
    set -l last_status $status

    if set -q VIRTUAL_ENV
        printf "%s❱%s" (set_color cyan) (set_color normal)
    end

    if set -q NODE_MODULES_PATH
        printf "%s❱%s" (set_color yellow) (set_color normal)
    end

    if set -q NVIM
        printf "🐢"
    end

    set -l jobs_list (jobs)
    if test -n "$jobs_list"
        set_color red
        printf "[%s]" (count $jobs_list)
        set_color normal
    end

    # PWD
    set_color $fish_color_cwd
    echo -n (prompt_pwd)
    set_color normal

    set -g __fish_git_prompt_showcolorhints true
    set -g __fish_git_prompt_show_informative_status true
    set -g ___fish_git_prompt_char_cleanstate ""
    set -g ___fish_git_prompt_char_stateseparator ""

    if not fish_jj_prompt
        fish_git_prompt
    end

    set_color normal

    echo

    if not test "$last_status" -eq 0
        set_color $fish_color_error
        echo -n $last_status
    end

    set_color normal

    # Change color based on mode
    # Do nothing if not in vi mode
    switch $fish_bind_mode
        case default
            set_color red
        case insert
            set_color green
        case visual
            set_color magenta
    end

    echo -n '% '
    set_color normal
end
