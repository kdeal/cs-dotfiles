return {
    -- Colorscheme
    {
        "EdenEast/nightfox.nvim",
        lazy = false,
        priority = 1000,
        opts = {
            options = {
                styles = {
                    comments = "italic",
                },
            },
            groups = {
                all = {
                    IblScope = { fg = "palette.blue" },
                },
            },
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
    -- Edit the filesystem as a buffer
    { "stevearc/oil.nvim", config = true, keys = { { "-", "<CMD>Oil<CR>", silent = true } } },
}
