local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
local utils = require("misc")

if not vim.loop.fs_stat(lazypath) then
    local lock_filepath = vim.fn.stdpath("config") .. "/lazy-lock.json"
    local lazy_lock_data = vim.json.decode(utils.read_file(lock_filepath))["lazy.nvim"]
    vim.fn.system({
        "git",
        "clone",
        "--filter=blob:none",
        "https://github.com/folke/lazy.nvim.git",
        string.format("--branch=%s", lazy_lock_data.branch), -- latest stable release
        lazypath,
    })
    vim.fn.system({
        "git",
        "-C",
        lazypath,
        "checkout",
        lazy_lock_data.commit,
    })
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
    -- Colorscheme
    { "morhetz/gruvbox", lazy = false, priority = 1000 },

    -- Easy commenting in any language
    "tpope/vim-commentary",

    -- Shortcuts for next and previous <quickfix|location>
    "tpope/vim-unimpaired",

    -- Git in vim
    {
        "tpope/vim-fugitive",
        keys = {
            { "<leader>ge", "<cmd>Gedit", silent = true },
            { "<leader>gl", "<cmd>Glog", silent = true },
            { "<leader>gb", "<cmd>Git blame<CR>", silent = true },
            { "<leader>gs", "<cmd>Git<CR>", silent = true },
        },
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
    { "folke/neodev.nvim", config = true },

    -- Shows language server progress
    {
        "j-hui/fidget.nvim",
        event = "VeryLazy",
        opts = {
            text = {
                spinner = { "▁", "▂", "▃", "▄", "▅", "▆", "▇", "█", "▇", "▆", "▅", "▄", "▃" },
            },
            align = {
                bottom = false,
            },
        },
    },

    -- Hook commands up to nvim lsp
    {
        "jose-elias-alvarez/null-ls.nvim",
        dependencies = "nvim-lua/plenary.nvim",
        event = "VeryLazy",
        config = function()
            require("null_ls_conf")
        end,
    },

    -- Lua helper library
    { "nvim-lua/plenary.nvim", lazy = true },

    -- Lua Fuzzy Finder
    {
        "nvim-telescope/telescope.nvim",
        keys = {
            { "<leader>/a", ":Telescope lsp_code_actions<CR>", silent = true },
            { "<leader>/b", ":Telescope buffers<CR>", silent = true },
            { "<leader>/e", ":Telescope loclist<CR>", silent = true },
            { "<leader>/f", ":Telescope find_files<CR>", silent = true },
            { "<leader>/g", ":Telescope live_grep<CR>", silent = true },
            { "<leader>/h", ":Telescope help_tags<CR>", silent = true },
            { "<leader>/r", ":Telescope registers<CR>", silent = true },
            { "<leader>/q", ":Telescope quickfix<CR>", silent = true },
        },
        config = true,
    },

    -- FZF like filtering for telescope
    {
        "nvim-telescope/telescope-fzf-native.nvim",
        build = "make",
        cmd = "Telescope",
        config = function()
            require("telescope").load_extension("fzf")
        end,
    },

    -- Lua completion tool
    {
        "hrsh7th/nvim-cmp",
        event = "InsertEnter",
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
        event = "InsertEnter",
        config = function()
            require("luasnip_conf")
        end,
    },

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
    { "nvim-treesitter/playground", cmd = "TSPlaygroundToggle" },

    -- Debugging things
    {
        "mfussenegger/nvim-dap",
        keys = {
            { "<leader>bt", "<cmd>lua require('dap').toggle_breakpoint()<cr>", silent = true },
            { "<leader>bc", "<cmd>lua require('dap').continue()<cr>", silent = true },
            { "<leader>bo", "<cmd>lua require('dap').step_over()<cr>", silent = true },
            { "<leader>bi", "<cmd>lua require('dap').step_into()<cr>", silent = true },
            { "<leader>bu", "<cmd>lua require('dap').step_out()<cr>", silent = true },
        },
    },

    {
        "mfussenegger/nvim-dap-python",
        dependencies = { "mfussenegger/nvim-dap" },
        ft = "python",
        config = function()
            local dap_python = require("dap-python")
            dap_python.setup()
            dap_python.test_runner = "pytest"
        end,
    },
    {
        "rcarriga/nvim-dap-ui",
        dependencies = { "mfussenegger/nvim-dap" },
        keys = { { "<leader>og", "<cmd>lua require('dapui').toggle()<cr>", silent = true } },
        config = true,
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
        opts = {
            signcolumn = false,
        },
        keys = { { "<leader>gd", "<cmd>Gitsigns toggle_signs<CR>", silent = true } },
    },

    {
        "folke/noice.nvim",
        event = "VeryLazy",
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
