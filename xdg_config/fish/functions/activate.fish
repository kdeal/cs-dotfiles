function activate
    argparse --name=activate q/quiet t/test -- $argv
    or return
    if set -q NODE_MODULES_PATH
        if not set -q _flag_quiet
            printf "%sAlready in node_modules!%s\n" (set_color red) (set_color normal)
        end
    else
        if [ -d "$PWD/node_modules" ]
            if set -q _flag_test
                return 1
            else if not set -q _flag_quiet
                echo "Sourcing node_modules"
            end
            activate_node_modules $PWD/node_modules
        end
    end

    set -l potential_venvs virtualenv_run venv devenv

    if set -q VIRTUAL_ENV
        if [ "$argv" != -q ]
            printf "%sAlready in virtual environment!%s\n" (set_color red) (set_color normal)
        end
    else
        for dir in $potential_venvs
            if [ -e "$PWD/$dir/bin/activate.fish" ]
                if set -q _flag_test
                    return 1
                else if not set -q _flag_quiet
                    printf "Sourcing %s$dir%s virtualenv\n" (set_color --bold green) (set_color normal)
                end
                activate_venv "$PWD/$dir"
                return
            end
        end
        if not set -q _flag_quiet
            echo "No virtualenv found"
        end
    end
    # If we are in test mode and didn't early return then fail
    if set -q _flag_test
        return 0
    end
end

function activate_venv
    # My fish_prompt checks if VIRTUAL_ENV variable is set and adjust the prompt
    set VIRTUAL_ENV_DISABLE_PROMPT true # The value doesn't actually matter
    source $argv/bin/activate.fish
end

function activate_node_modules
    set -g NODE_MODULES_PATH $argv/.bin
    set -x PATH $NODE_MODULES_PATH $PATH
end
