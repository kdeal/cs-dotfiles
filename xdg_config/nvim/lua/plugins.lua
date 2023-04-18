local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"

if not vim.loop.fs_stat(lazypath) then
    vim.fn.system({
        "git",
        "clone",
        "--filter=blob:none",
        "https://github.com/folke/lazy.nvim.git",
        "--branch=stable", -- latest stable release
        lazypath,
    })
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
    -- Colorscheme
    "morhetz/gruvbox",

    -- Easy commenting in any language
    "tpope/vim-commentary",

    -- Shortcuts for next and previous <quickfix|location>
    "tpope/vim-unimpaired",

    -- Git in vim
    {
        "tpope/vim-fugitive",
        config = function()
            require("fugitive_conf")
        end,
    },

    -- Repeat stuff
    "tpope/vim-repeat",

    -- Adds vim commands that wrap common file operations
    {
        "tpope/vim-eunuch",
        cmd = { "Delete", "Unlink", "Move", "Rename", "Chmod", "Mkdir", "SudoWrite", "SudoEdit" },
    },

    -- Set the cwd to repo root
    "airblade/vim-rooter",

    -- Undo tree viewer
    { "mbbill/undotree", cmd = "UndotreeToggle" },

    -- Show how far indented a line is
    {
        "lukas-reineke/indent-blankline.nvim",
        config = function()
            require("indent_conf")
        end,
    },

    -- Fuzzy finding all the things
    { "junegunn/fzf", build = "./install --all --no-zsh --no-bash" },

    -- Syntax and highlighting for languages
    "Vimjas/vim-python-pep8-indent",

    -- Visual made * and # search
    "bronson/vim-visual-star-search",

    -- Move function argument left or right
    {
        "AndrewRadev/sideways.vim",
        cmd = { "SidewaysLeft", "SidewaysRight" },
    },
    -- Join or split things (lists, function line, tuples)
    "AndrewRadev/splitjoin.vim",

    -- Config for neovim language servers
    {
        "neovim/nvim-lspconfig",
        config = function()
            require("lsp_conf")
        end,
    },

    -- Shows language server progress
    {
        "j-hui/fidget.nvim",
        config = function()
            require("fidget_conf")
        end,
    },

    -- Hook commands up to nvim lsp
    {
        "jose-elias-alvarez/null-ls.nvim",
        dependencies = "nvim-lua/plenary.nvim",
        config = function()
            require("null_ls_conf")
        end,
    },

    -- Lua helper library
    "nvim-lua/plenary.nvim",

    -- Lua Fuzzy Finder
    {
        "nvim-telescope/telescope.nvim",
        config = function()
            require("telescope_conf")
        end,
    },

    -- FZF like filtering for telescope
    { "nvim-telescope/telescope-fzf-native.nvim", build = "make" },

    -- Lua completion tool
    {
        "hrsh7th/nvim-cmp",
        dependencies = {
            "hrsh7th/cmp-nvim-lsp",
            "hrsh7th/cmp-buffer",
            "hrsh7th/cmp-path",
            "saadparwaiz1/cmp_luasnip",
            "L3MON4D3/LuaSnip",
        },
        config = function()
            require("cmp_conf")
        end,
    },

    {
        "L3MON4D3/LuaSnip",
        config = function()
            require("luasnip_conf")
        end,
    },

    -- Simplifies the Vim ui to help you to focus on writing
    "junegunn/goyo.vim",

    -- Javascript stuff
    "pangloss/vim-javascript",

    -- Tree sitter based syntax highlighting
    {
        "nvim-treesitter/nvim-treesitter",
        build = function()
            require("nvim-treesitter.install").update({ with_sync = true })
        end,
        config = function()
            require("treesitter_conf")
        end,
    },

    -- Debugging things
    {
        "mfussenegger/nvim-dap",
        config = function()
            require("dap_conf")
        end,
    },

    {
        "mfussenegger/nvim-dap-python",
        dependencies = { "mfussenegger/nvim-dap" },
        config = function()
            require("dap_python_conf")
        end,
    },
    {
        "rcarriga/nvim-dap-ui",
        dependencies = { "mfussenegger/nvim-dap" },
        config = function()
            require("dapui_conf")
        end,
    },

    -- Show tests in a side panel
    {
        "nvim-neotest/neotest",
        dependencies = {
            "nvim-lua/plenary.nvim",
            "nvim-treesitter/nvim-treesitter",
            -- This isn't really required, but is lang implementations for it
            "nvim-neotest/neotest-go",
            "nvim-neotest/neotest-python",
        },
        config = function()
            require("neotest_conf")
        end,
    },

    {
        "lewis6991/gitsigns.nvim",
        dependencies = {
            "nvim-lua/plenary.nvim",
        },
        config = function()
            require("gitsigns_conf")
        end,
    },

    {
        "folke/noice.nvim",
        config = function()
            require("noice_conf")
        end,
        dependencies = {
            "MunifTanjim/nui.nvim",
            "rcarriga/nvim-notify",
        },
    },
}, {
    ui = {
        icons = {
            cmd = "⌘",
            config = "🛠",
            event = "📅",
            ft = "📂",
            init = "⚙",
            keys = "🗝",
            plugin = "🔌",
            runtime = "💻",
            source = "📄",
            start = "🚀",
            task = "📌",
            lazy = "💤 ",
        },
    },
})
