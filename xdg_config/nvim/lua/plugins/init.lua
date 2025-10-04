return {
    -- Colorscheme
    {
        "neanias/everforest-nvim",
        lazy = false,
        priority = 1000,
        main = "everforest",
        opts = {
            on_highlights = function(hl, palette)
                hl.StatusLineReadOnly = { fg = palette.red, bg = palette.bg2 }
                hl.StatusLineCenter = { fg = palette.fg, bg = palette.bg2 }
                hl.StatusLineModified = { fg = palette.orange, bg = palette.bg2, bold = true }
                hl.StatusLineDiagnostics = { fg = palette.bg_dim, bg = palette.red }
                hl.StatusLineEnds = { fg = palette.bg0, bg = palette.statusline1 }
                hl.StatusLineSecond = { fg = palette.bg0, bg = palette.statusline2 }
            end,
        },
    },

    -- Repeat stuff
    "tpope/vim-repeat",

    -- Adds vim commands that wrap common file operations
    {
        "tpope/vim-eunuch",
        cmd = { "Delete", "Unlink", "Move", "Rename", "Chmod", "Mkdir", "SudoWrite", "SudoEdit" },
    },

    -- Show how far indented a line is
    {
        "lukas-reineke/indent-blankline.nvim",
        config = function()
            require("ibl").setup({
                scope = { show_start = false, show_end = false },
                indent = { tab_char = "║" },
            })
            local hooks = require("ibl.hooks")
            hooks.register(hooks.type.WHITESPACE, hooks.builtin.hide_first_space_indent_level)
            hooks.register(hooks.type.WHITESPACE, hooks.builtin.hide_first_tab_indent_level)
        end,
    },

    -- Fuzzy finding all the things
    { "junegunn/fzf", build = "./install --all --no-zsh --no-bash" },

    -- Visual made * and # search
    "bronson/vim-visual-star-search",

    -- Move function argument left or right
    {
        "AndrewRadev/sideways.vim",
        keys = {
            { "gsh", "<cmd>SidewaysLeft<CR>", silent = true },
            { "gsl", "<cmd>SidewaysRight<CR>", silent = true },
        },
        cmd = { "SidewaysLeft", "SidewaysRight" },
    },
    -- Lua helper library
    { "nvim-lua/plenary.nvim", lazy = true },

    -- Guess file indent plugin
    {
        "NMAC427/guess-indent.nvim",
        opts = {},
    },
    {
        "folke/snacks.nvim",
        priority = 999,
        lazy = false,
        keys = {
            -- Picker commands
            {
                "<leader>pb",
                function()
                    Snacks.picker.buffers()
                end,
                silent = true,
            },
            {
                "<leader>pd",
                function()
                    Snacks.picker.diagnostics()
                end,
                silent = true,
            },
            {
                "<leader>pe",
                function()
                    Snacks.picker.loclist()
                end,
                silent = true,
            },
            {
                "<leader>pf",
                function()
                    Snacks.picker.files()
                end,
                silent = true,
            },
            {
                "<leader>pF",
                function()
                    Snacks.picker.smart()
                end,
                silent = true,
            },
            {
                "<leader>pg",
                function()
                    Snacks.picker.grep()
                end,
                silent = true,
            },
            {
                "<leader>ph",
                function()
                    Snacks.picker.help()
                end,
                silent = true,
            },
            {
                "<leader>pq",
                function()
                    Snacks.picker.qflist()
                end,
                silent = true,
            },
            -- Buffer delete
            {
                "<leader>bd",
                function()
                    Snacks.bufdelete.delete()
                end,
                silent = true,
            },
            -- Scratch
            {
                "<leader>.",
                function()
                    Snacks.scratch()
                end,
                desc = "Toggle Scratch Buffer",
            },
            -- Git Browse
            {
                "<leader>gB",
                function()
                    Snacks.gitbrowse()
                end,
                desc = "Git Browse",
                mode = { "n", "v" },
            },
            {
                "<leader>gb",
                function()
                    Snacks.git.blame_line()
                end,
                desc = "Git Blame line",
            },
            -- References
            {
                "]]",
                function()
                    Snacks.words.jump(vim.v.count1)
                end,
                desc = "Next Reference",
                mode = { "n", "t" },
            },
            {
                "[[",
                function()
                    Snacks.words.jump(-vim.v.count1)
                end,
                desc = "Prev Reference",
                mode = { "n", "t" },
            },
        },
        ---@type snacks.Config
        opts = {
            bigfile = { enabled = true },
            dashboard = { enabled = true },
            explorer = { enabled = true },
            indent = {
                -- It doesn't support showing tabs vs spaces
                enabled = false,
                scope = { enabled = false },
            },
            picker = { enabled = true },
            notifier = { enabled = true },
            quickfile = { enabled = true },
            scope = { enabled = true },
            scroll = { enabled = true },
            statuscolumn = { enabled = true },
            words = { enabled = true },
        },
    },
}
