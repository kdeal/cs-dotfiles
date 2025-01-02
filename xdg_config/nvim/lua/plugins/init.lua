return {
    -- Colorscheme
    {
        "neanias/everforest-nvim",
        lazy = false,
        priority = 1000,
        main = "everforest",
        opts = {
            on_highlights = function(hl, palette)
                hl.StatusLineReadOnly = { fg = palette.red, bg = palette.bg3 }
                hl.StatusLineCenter = { fg = palette.fg, bg = palette.bg3 }
                hl.StatusLineModified = { fg = palette.orange, bg = palette.bg3, bold = true }
                hl.StatusLineDiagnostics = { fg = palette.bg_dim, bg = palette.red }
                hl.StatusLineEnds = { fg = palette.fg, bg = palette.bg4 }
                hl.StatusLineSecond = { fg = palette.fg, bg = palette.bg5 }
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
            })
            local hooks = require("ibl.hooks")
            hooks.register(hooks.type.WHITESPACE, hooks.builtin.hide_first_space_indent_level)
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
}
