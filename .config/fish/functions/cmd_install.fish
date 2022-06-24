function cmd_install --description="Install extra commands that I might want"
    switch $argv[1]
        case "nvim"
            set -l tmp_file (mktemp)
            curl --progress-bar --output "$tmp_file" --location https://github.com/neovim/neovim/releases/download/nightly/nvim-linux64.tar.gz
            set -l file_hash (sha256sum "$tmp_file" | string match --regex "^[0-9a-f]+")
            echo "Get tar hash from https://github.com/neovim/neovim/releases/nightly"
            read -l --prompt-str "Enter tar hash: " input_hash
            if test "$input_hash" = "$file_hash"
                tar xzf "$tmp_file" -C ~/.cmds/
                ln -s ~/.cmds/nvim-linux64/bin/nvim ~/.local/bin/
                # Update abbrs to make edit expand to nvim
                update_abbrs
                # Reload editor settings
                source ~/.config/fish/conf.d/editor.fish
            else
                echo "Hashes don't match expected: $input_hash, actual: $file_hash"
            end
        case '' '*'
            echo "Command not recognized: \"$argv[1]\""
    end
end
