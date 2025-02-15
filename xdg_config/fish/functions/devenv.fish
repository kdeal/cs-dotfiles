function devenv
    set -l env $argv[1]
    if [ -z "$env" ]
        if [ -e pyproject.toml ]
            set env python
        else if [ -d xdg_config ]
            set env lua
        else if [ -e cargo.toml ]
            set env rust
        else
            set env base
        end
    end


    set -l packages bat delta eza fd nvim rg
    switch $env
        case go
            set -a packages gopls
        case lua
            set -a packages lua_ls
        case python
            set -a packages pyright debugpy
        case rust
            set -a packages rustfmt rust-analyzer
    end

    if [ -e .pre-commit-config.yaml ]
        set -a packages pre-commit
    end
    if [ -e justfile ]
        set -a packages just
    end

    printf "Installing packages for the %s$env%s environment (%s$packages%s)\n" (set_color green) (set_color normal) (set_color yellow) (set_color normal)
    cmd_install $packages
end
