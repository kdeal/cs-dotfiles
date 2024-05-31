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
            set -l nvim_hash be1f0988d0de71c375982b87b86cd28d2bab35ece8285abe3b0aac57604dfc5a
            set -l url "https://github.com/neovim/neovim/releases/download/v0.10.0/nvim-linux64.tar.gz"
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
            set -l rg_hash f84757b07f425fe5cf11d87df6644691c644a5cd2348a2c670894272999d3ba7
            set -l url "https://github.com/BurntSushi/ripgrep/releases/download/14.1.0/ripgrep-14.1.0-x86_64-unknown-linux-musl.tar.gz"
            set -l tmp_file (__cmd_install_checksha_download $url $rg_hash)
            if test -n "$tmp_file"
                tar xzf "$tmp_file" -C "$CACHE_DIR"
                cp "$CACHE_DIR/ripgrep-14.1.0-x86_64-unknown-linux-musl/rg" "$BIN_DIR"
                cp "$CACHE_DIR/ripgrep-14.1.0-x86_64-unknown-linux-musl/complete/rg.fish" ~/.config/fish/completions/
                # Update abbrs to make grep expand to rg
                update_abbrs
            else
                echo "Hashes don't match expected"
            end
        case debugpy
            if command -q pip
                pip install debugpy==1.8.1
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
            set -l helix_hash 60d6337c4d748cef1f936cde66dc7dbd009c70a7f068c96cfc319250e513256f
            set -l url "https://github.com/helix-editor/helix/releases/download/23.10/helix-23.10-x86_64.AppImage"
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
            set -l fd_hash 069e2d58127ddd944c03a2684ad79f72e3f9bd3e0d2642c36adc5b367c134592
            set -l url "https://github.com/sharkdp/fd/releases/download/v9.0.0/fd-v9.0.0-x86_64-unknown-linux-musl.tar.gz"
            set -l tmp_file (__cmd_install_checksha_download $url $fd_hash)
            if test -n "$tmp_file"
                tar xzf "$tmp_file" -C "$CACHE_DIR"
                cp "$CACHE_DIR/fd-v9.0.0-x86_64-unknown-linux-musl/fd" "$BIN_DIR"
                cp $CACHE_DIR/fd-v9.0.0-x86_64-unknown-linux-musl/autocomplete/fd.fish $HOME/.config/fish/completions/
            else
                echo "Hashes don't match expected"
            end
        case lua_ls
            set -l lua_ls_hash e8aaabfa3b94b9afa51245d4ca73fe8196ac31625653b8dd83f6027183f596a5
            set -l url "https://github.com/LuaLS/lua-language-server/releases/download/3.7.4/lua-language-server-3.7.4-linux-x64.tar.gz"
            set -l tmp_file (__cmd_install_checksha_download $url $lua_ls_hash)
            if test -n "$tmp_file"
                mkdir -p $HOME/.local/share/lua_ls/
                tar xzf "$tmp_file" -C "$HOME/.local/share/lua_ls/"
                echo -e "#!/bin/bash\nexec \"$HOME/.local/share/lua_ls/bin/lua-language-server\" \"\$@\"" >$BIN_DIR/lua-language-server
                chmod +x $BIN_DIR/lua-language-server
            else
                echo "Hashes don't match expected"
            end
        case rustfmt
            if command -q rustup
                rustup component add rustfmt
            else
                printf "%sERROR:%s rustup unavailable can't install %srustfmt%s\n" (set_color red) (set_color normal) (set_color yellow) (set_color normal)
            end
        case rust-analyzer
            set -l rust_analyzer_hash 80d1a59e87820b65d4a86e6994a5dfda14edfd9fb5133a2394f28634bbc19eb2
            set -l url "https://github.com/rust-lang/rust-analyzer/releases/download/2024-02-19/rust-analyzer-x86_64-unknown-linux-musl.gz"
            set -l tmp_file (__cmd_install_checksha_download $url $rust_analyzer_hash)
            if [ -n "$tmp_file" ]
                gunzip -c $tmp_file >$BIN_DIR/rust-analyzer
                chmod +x $BIN_DIR/rust-analyzer
            else
                printf "%sError:%s Hashes don't match expected for %srust-analyzer%s\n" (set_color red) (set_color normal) (set_color yellow) (set_color normal)
            end
        case typescript-language-server
            if command -q npm
                npm install -g typescript typescript-language-server
            end
        case tailwindcss-language-server
            if command -q npm
                npm install -g @tailwindcss/language-server
            end
        case '' '*'
            echo "Command not recognized: \"$argv[1]\""
    end
end
