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

    set -l CACHE_DIR "$HOME/.cache"
    set -l BIN_DIR "$HOME/.local/bin"
    mkdir -p "$CACHE_DIR" "$BIN_DIR"

    switch $argv[1]
        case nvim
            set -l nvim_hash 1af27471f76f1b4f7ad6563c863a4a78117f0515e3390ee4d911132970517fa7
            set -l url "https://github.com/neovim/neovim/releases/download/v0.8.0/nvim-linux64.tar.gz"
            set -l tmp_file (__cmd_install_checksha_download $url $nvim_hash)

            if test -n "$tmp_file"
                tar xzf "$tmp_file" -C "$CACHE_DIR"
                rsync -a "$CACHE_DIR/nvim-linux64/" ~/.local/
                # Update abbrs to make edit expand to nvim
                update_abbrs
                # Reload editor settings
                source ~/.config/fish/conf.d/editor.fish
            else
                echo "Hashes don't match expected"
            end
        case rg
            set -l rg_hash ee4e0751ab108b6da4f47c52da187d5177dc371f0f512a7caaec5434e711c091
            set -l url "https://github.com/BurntSushi/ripgrep/releases/download/13.0.0/ripgrep-13.0.0-x86_64-unknown-linux-musl.tar.gz"
            set -l tmp_file (__cmd_install_checksha_download $url $rg_hash)
            if test -n "$tmp_file"
                tar xzf "$tmp_file" -C "$CACHE_DIR"
                cp "$CACHE_DIR/ripgrep-13.0.0-x86_64-unknown-linux-musl/rg" "$BIN_DIR"
                # Update abbrs to make grep expand to rg
                update_abbrs
            else
                echo "Hashes don't match expected"
            end
        case debugpy
            if command -q pip
                pip install debugpy==1.6.3
            else
                echo "Pip unavailable can't install"
            end
        case gopls
            if command -q go
                go install golang.org/x/tools/gopls@latest
            else
                echo "Go unavailable can't install"
            end
        case pre-commit
            if command -q virtualenv
                mkdir -p "$HOME/.local/share/pre-commit"
                virtualenv "$HOME/.local/share/pre-commit/venv"
                $HOME/.local/share/pre-commit/venv/bin/pip install pre-commit
                ln -s "$HOME/.local/share/pre-commit/venv/bin/pre-commit" "$BIN_DIR/"
                if git rev-parse
                    pre-commit install
                end
            else
                echo "virtualenv unavailable can't install"
            end
        case pyright
            if command -q npm
                npm install -g pyright
            end
        case delta
            set -l delta_hash f2499f34a4355a808c084764dcb37b613af4d45af28d8f8fb5a0739eeb2839f9
            set -l url "https://github.com/dandavison/delta/releases/download/0.15.1/delta-0.15.1-x86_64-unknown-linux-musl.tar.gz"
            set -l tmp_file (__cmd_install_checksha_download $url $delta_hash)
            if test -n "$tmp_file"
                tar xzf "$tmp_file" -C "$CACHE_DIR"
                cp "$CACHE_DIR/delta-0.15.1-x86_64-unknown-linux-musl/delta" "$BIN_DIR"
            end
        case bat
            set -l bat_hash 917844685025552d9fb3d66e233ce55d3b3c2ea85a6c0ad3dc703705adea9525
            set -l url "https://github.com/sharkdp/bat/releases/download/v0.22.1/bat-v0.22.1-x86_64-unknown-linux-musl.tar.gz"
            set -l tmp_file (__cmd_install_checksha_download $url $bat_hash)
            if test -n "$tmp_file"
                tar xzf "$tmp_file" -C "$CACHE_DIR"
                cp "$CACHE_DIR/bat-v0.22.1-x86_64-unknown-linux-musl/bat" "$BIN_DIR"
                cp "$CACHE_DIR/bat-v0.22.1-x86_64-unknown-linux-musl/autocomplete/bat.fish" ~/.config/fish/completions/
                # Update abbrs to make cat expand to rg
                update_abbrs
            else
                echo "Hashes don't match expected"
            end
        case '' '*'
            echo "Command not recognized: \"$argv[1]\""
    end
end
