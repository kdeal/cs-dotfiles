return {
    {
        "echasnovski/mini.nvim",
        lazy = false,
        keys = {
            -- Have to reenable the plugin, since I disable it during startup
            { "<leader>gd", "<cmd>lua vim.g.minidiff_disable = false; MiniDiff.toggle()<cr>", silent = true },
            { "<leader>gb", "<cmd>vertical leftabove Git blame --date human -- %<cr>", silent = true },
            -- Picker commands
            { "<leader>/b", "<cmd>Pick buffers<cr>", silent = true },
            { "<leader>/d", "<cmd>Pick diagnostics<cr>", silent = true },
            { "<leader>/e", "<cmd>Pick list scop='location-list'<cr>", silent = true },
            { "<leader>/f", "<cmd>Pick files<cr>", silent = true },
            { "<leader>/g", "<cmd>Pick grep_live<cr>", silent = true },
            { "<leader>/h", "<cmd>Pick help<cr>", silent = true },
            { "<leader>/q", "<cmd>Pick list scop='quickfix'<cr>", silent = true },
            { "<leader>/s", "<cmd>Pick spellsuggest<cr>", silent = true },
        },
        config = function()
            -- Better Around/Inside textobjects
            require("mini.ai").setup({ n_lines = 500 })
            -- Shortcuts for next and previous <quickfix|location>
            require("mini.bracketed").setup()
            -- Buffer removing (unshow, delete, wipeout), which saves window layout
            require("mini.bufremove").setup()
            -- Automatic read/write of session
            require("mini.sessions").setup()
            require("mini.splitjoin").setup()
            -- Easily change surrounding characters
            require("mini.surround").setup()
            -- Disable during setup, so it doesn't get enabled on buffers at startup
            vim.g.minidiff_disable = true
            -- Show git diff status in status line
            require("mini.diff").setup()

            -- Remove the auto-enable autocommand to disable it
            local autocommands = vim.api.nvim_get_autocmds({ group = "MiniDiff", event = "BufEnter" })
            for _, au_cmd in pairs(autocommands) do
                if au_cmd.desc == "Enable diff" then
                    vim.api.nvim_del_autocmd(au_cmd.id)
                end
            end

            -- Basic git interactions
            require("mini.git").setup()

            -- Keep blame aligned with buffer from the help doc
            local align_blame = function(au_data)
                if au_data.data.git_subcommand ~= "blame" then
                    return
                end

                -- Align blame output with source
                local win_src = au_data.data.win_source
                vim.wo.wrap = false
                vim.fn.winrestview({ topline = vim.fn.line("w0", win_src) })
                vim.api.nvim_win_set_cursor(0, { vim.fn.line(".", win_src), 0 })

                -- Bind both windows so that they scroll together
                vim.wo[win_src].scrollbind, vim.wo.scrollbind = true, true

                -- Remove the file contents, since it is in the split next to this one
                vim.cmd("%s/\\s\\+\\d\\+).*/")

                -- Resize the blame window to the max line length
                local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
                local max_line_len = 0
                for _, line in pairs(lines) do
                    max_line_len = math.max(string.len(line), max_line_len)
                end
                vim.api.nvim_win_set_width(0, max_line_len + 1)
            end

            local au_opts = { pattern = "MiniGitCommandSplit", callback = align_blame }
            vim.api.nvim_create_autocmd("User", au_opts)

            require("mini.pick").setup()
            -- Add for some more pickers
            require("mini.extra").setup()

            require("mini.misc").setup()
            MiniMisc.setup_auto_root({ "Cargo.toml", "package.json", ".git" })
            MiniMisc.setup_restore_cursor()

            -- Try out doing auto-pairs
            require("mini.pairs").setup()
        end,
    },
}
