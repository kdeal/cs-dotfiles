function cmd_install --description="Install extra commands that I might want"
    function __cmd_install_checksha_download
        # arg1 = url, arg2 = sha
        set -l tmp_file (mktemp)
        curl --progress-bar --output "$tmp_file" --location "$argv[1]"
        set -l file_hash (sha256sum "$tmp_file" | string match --regex "^[0-9a-f]+")
        if test "$argv[2]" = "$file_hash"
            echo $tmp_file
            return 0
        else
            return 1
        end
    end
    switch $argv[1]
        case "nvim"
            echo "https://github.com/neovim/neovim/releases/tag/nightly"
            read -l --prompt-str "Enter tar hash: " input_hash
            set -l url "https://github.com/neovim/neovim/releases/download/nightly/nvim-linux64.tar.gz"
            set -l tmp_file (__cmd_install_checksha_download $url $input_hash)

            if test -n "$tmp_file"
                tar xzf "$tmp_file" -C ~/.cmds/
                ln -s ~/.cmds/nvim-linux64/bin/nvim ~/.local/bin/
                # Update abbrs to make edit expand to nvim
                update_abbrs
                # Reload editor settings
                source ~/.config/fish/conf.d/editor.fish
            else
                echo "Hashes don't match expected"
            end
        case "rg"
            set -l rg_hash "ee4e0751ab108b6da4f47c52da187d5177dc371f0f512a7caaec5434e711c091"
            set -l url "https://github.com/BurntSushi/ripgrep/releases/download/13.0.0/ripgrep-13.0.0-x86_64-unknown-linux-musl.tar.gz"
            set -l tmp_file (__cmd_install_checksha_download $url $rg_hash)
            if test -n "$tmp_file"
                tar xzf "$tmp_file" -C ~/.cmds/
                ln -s ~/.cmds/ripgrep-13.0.0-x86_64-unknown-linux-musl/rg ~/.local/bin/
                # Update abbrs to make grep expand to rg
                update_abbrs
            else
                echo "Hashes don't match expected"
            end
        case "debugpy"
            if command -q "pip"
                pip install debugpy==1.6.3
            else
                echo "Pip unavailable can't install"
            end
        case '' '*'
            echo "Command not recognized: \"$argv[1]\""
    end
end
