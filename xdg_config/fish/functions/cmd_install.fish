function cmd_install --description="Install extra commands that I might want"
    for cmd in $argv
        __cmd_install_single_command $cmd
    end
end

function __cmd_install_single_command
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
            set -l nvim_hash 6c083017304213c3a3efde8d332a52231b8df8206d35146942097c303ebf93d5
            set -l url "https://github.com/neovim/neovim/releases/download/v0.9.1/nvim-linux64.tar.gz"
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
                pip install debugpy==1.6.7
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
            set -l delta_hash 737d318ab15d4ca68e3bdb0753867d0d3944ff78d37fc44c79941104fbbdbb12
            set -l url "https://github.com/dandavison/delta/releases/download/0.16.5/delta-0.16.5-x86_64-unknown-linux-musl.tar.gz"
            set -l tmp_file (__cmd_install_checksha_download $url $delta_hash)
            if test -n "$tmp_file"
                tar xzf "$tmp_file" -C "$CACHE_DIR"
                cp "$CACHE_DIR/delta-0.16.5-x86_64-unknown-linux-musl/delta" "$BIN_DIR"
            end
        case bat
            set -l bat_hash e7f97bc826878283775fdb02a53a871fab1be920b921057549b2bc7da81bb771
            set -l url "https://github.com/sharkdp/bat/releases/download/v0.23.0/bat-v0.23.0-x86_64-unknown-linux-musl.tar.gz"
            set -l tmp_file (__cmd_install_checksha_download $url $bat_hash)
            if test -n "$tmp_file"
                tar xzf "$tmp_file" -C "$CACHE_DIR"
                cp "$CACHE_DIR/bat-v0.23.0-x86_64-unknown-linux-musl/bat" "$BIN_DIR"
                cp "$CACHE_DIR/bat-v0.23.0-x86_64-unknown-linux-musl/autocomplete/bat.fish" ~/.config/fish/completions/
                # Update abbrs to make cat expand to rg
                update_abbrs
            else
                echo "Hashes don't match expected"
            end
        case helix
            set -l helix_hash c3840a51ef6a255eed192e7d7b929d37d280345ee165f819718bd016ae3f46be
            set -l url "https://github.com/helix-editor/helix/releases/download/23.03/helix-23.03-x86_64.AppImage"
            set -l tmp_file (__cmd_install_checksha_download $url $helix_hash)
            if test -n "$tmp_file"
                chmod +x "$tmp_file"
                mkdir $CACHE_DIR/helix
                cd $CACHE_DIR/helix
                command $tmp_file --appimage-extract
                cp -r squashfs-root/usr/* $HOME/.local/
                rm -r squashfs-root/
                prevd
            else
                echo "Hashes don't match expected"
            end
        case exa
            set -l exa_hash a65a87bd545e969979ae9388f6333167f041a1f09fa9d60b32fd3072348ff6ce
            set -l url "https://github.com/ogham/exa/releases/download/v0.10.1/exa-linux-x86_64-v0.10.1.zip"
            set -l tmp_file (__cmd_install_checksha_download $url $exa_hash)
            if test -n "$tmp_file"
                mkdir $CACHE_DIR/exa
                unzip $tmp_file -d $CACHE_DIR/exa
                cp $CACHE_DIR/exa/bin/exa $BIN_DIR
                cp $CACHE_DIR/exa/man/* $HOME/.local/share/man/man1/
                cp $CACHE_DIR/exa/completions/exa.fish $HOME/.config/fish/completions/
                # Update abbrs to make ls expand to exa
                update_abbrs
            else
                echo "Hashes don't match expected"
            end
        case fd
            set -l fd_hash ced2541984b765994446958206b3411f3dea761a5e618cb18b4724c523727d68
            set -l url "https://github.com/sharkdp/fd/releases/download/v8.7.0/fd-v8.7.0-x86_64-unknown-linux-musl.tar.gz"
            set -l tmp_file (__cmd_install_checksha_download $url $fd_hash)
            if test -n "$tmp_file"
                tar xzf "$tmp_file" -C "$CACHE_DIR"
                cp "$CACHE_DIR/fd-v8.7.0-x86_64-unknown-linux-musl/fd" "$BIN_DIR"
                cp $CACHE_DIR/fd-v8.7.0-x86_64-unknown-linux-musl/autocomplete/fd.fish $HOME/.config/fish/completions/
                # Update abbrs to make grep expand to rg
                update_abbrs
            else
                echo "Hashes don't match expected"
            end
        case '' '*'
            echo "Command not recognized: \"$argv[1]\""
    end
end
