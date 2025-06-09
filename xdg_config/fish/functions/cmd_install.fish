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
            set -l nvim_hash a9b24157672eb218ff3e33ef3f8c08db26f8931c5c04bdb0e471371dd1dfe63e
            set -l url "https://github.com/neovim/neovim/releases/download/v0.11.2/nvim-linux-x86_64.tar.gz"
            set -l tmp_file (__cmd_install_checksha_download $url $nvim_hash)

            if test -n "$tmp_file"
                tar xzf "$tmp_file" -C "$CACHE_DIR"
                rsync -a "$CACHE_DIR/nvim-linux-x86_64/" ~/.local/
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
            set -l delta_hash b7ea845004762358a00ef9127dd9fd723e333c7e4b9cb1da220c3909372310ee
            set -l delta_version "0.18.2"
            set -l url "https://github.com/dandavison/delta/releases/download/$delta_version/delta-$delta_version-x86_64-unknown-linux-musl.tar.gz"
            set -l tmp_file (__cmd_install_checksha_download $url $delta_hash)
            if test -n "$tmp_file"
                tar xzf "$tmp_file" -C "$CACHE_DIR"
                cp "$CACHE_DIR/delta-$delta_version-x86_64-unknown-linux-musl/delta" "$BIN_DIR"
            end
        case bat
            set -l bat_hash d39a21e3da57fe6a3e07184b3c1dc245f8dba379af569d3668b6dcdfe75e3052
            set -l bat_version "0.24.0"
            set -l url "https://github.com/sharkdp/bat/releases/download/v$bat_version/bat-v$bat_version-x86_64-unknown-linux-musl.tar.gz"
            set -l tmp_file (__cmd_install_checksha_download $url $bat_hash)
            if test -n "$tmp_file"
                tar xzf "$tmp_file" -C "$CACHE_DIR"
                cp "$CACHE_DIR/bat-v$bat_version-x86_64-unknown-linux-musl/bat" "$BIN_DIR"
                cp "$CACHE_DIR/bat-v$bat_version-x86_64-unknown-linux-musl/autocomplete/bat.fish" ~/.config/fish/completions/
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
        case eza
            set -l eza_hash cb5953a866a5fb3ec8d4fb0f6b0275511c5caa4d6b3019e5378d970ea85d2ef0
            set -l url "https://github.com/eza-community/eza/releases/download/v0.20.14/eza_x86_64-unknown-linux-musl.tar.gz"
            set -l tmp_file (__cmd_install_checksha_download $url $eza_hash)
            if test -n "$tmp_file"
                tar xzf "$tmp_file" -C "$CACHE_DIR"
                cp $CACHE_DIR/eza $BIN_DIR
                # Update abbrs to make ls expand to eza
                update_abbrs
            else
                echo "Hashes don't match expected"
            end
        case fd
            set -l fd_hash d9bfa25ec28624545c222992e1b00673b7c9ca5eb15393c40369f10b28f9c932
            set -l fd_version "10.2.0"
            set -l url "https://github.com/sharkdp/fd/releases/download/v$fd_version/fd-v$fd_version-x86_64-unknown-linux-musl.tar.gz"
            set -l tmp_file (__cmd_install_checksha_download $url $fd_hash)
            if test -n "$tmp_file"
                tar xzf "$tmp_file" -C "$CACHE_DIR"
                cp "$CACHE_DIR/fd-v$fd_version-x86_64-unknown-linux-musl/fd" "$BIN_DIR"
                cp $CACHE_DIR/fd-v$fd_version-x86_64-unknown-linux-musl/autocomplete/fd.fish $HOME/.config/fish/completions/
            else
                echo "Hashes don't match expected"
            end
        case lua_ls
            set -l lua_ls_hash 5d4316291b8c79b145002318fbb7cc294a327c314e2711e590609b178478eb59
            set -l url "https://github.com/LuaLS/lua-language-server/releases/download/3.13.5/lua-language-server-3.13.5-linux-x64.tar.gz"
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
        case css-language-server html-language-server
            if command -q npm
                npm install -g vscode-langservers-extracted
            end
        case just
            set -l just_hash c803e67fd7b0af01667bd537197bc3df319938eacf9e8d51a441c71d03035bb5
            set -l url "https://github.com/casey/just/releases/download/1.38.0/just-1.38.0-x86_64-unknown-linux-musl.tar.gz"
            set -l tmp_file (__cmd_install_checksha_download $url $just_hash)
            if [ -n "$tmp_file" ]
                mkdir "$CACHE_DIR/just"
                tar xzf "$tmp_file" -C "$CACHE_DIR/just"
                cp "$CACHE_DIR/just/just" "$BIN_DIR"
                cp "$CACHE_DIR/just/just.1" "$HOME/.local/share/man/man1/"
                cp "$CACHE_DIR/just/completions/just.fish" $HOME/.config/fish/completions/
            else
                printf "%sError:%s Hashes don't match expected for %sjust%s\n" (set_color red) (set_color normal) (set_color yellow) (set_color normal)
            end
        case codex
            if command -q npm
                npm install -g @openai/codex
            else
                echo "npm unavailable can't install codex"
            end

        case claude
            if command -q npm
                npm install -g @anthropic-ai/claude-code
            else
                echo "npm unavailable can't install claude"
            end

        case '' '*'
            echo "Command not recognized: \"$argv[1]\""
    end
end
