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

    -- Git in vim
    {
        "tpope/vim-fugitive",
        ft = "gitcommit",
        cmd = "Git",
        keys = {
            { "<leader>ge", "<cmd>Gedit<cr>", silent = true },
            { "<leader>gl", "<cmd>Glog<cr>", silent = true },
            { "<leader>gb", "<cmd>Git blame<cr>", silent = true },
            { "<leader>gs", "<cmd>Git<cr>", silent = true },
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
        keys = {
            { "gsh", "<cmd>SidewaysLeft<CR>", silent = true },
            { "gsl", "<cmd>SidewaysRight<CR>", silent = true },
        },
        cmd = { "SidewaysLeft", "SidewaysRight" },
    },

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
            notification = {
                window = {
                    align = "top",
                },
            },
        },
    },
    -- Runs formatters
    {
        "stevearc/conform.nvim",
        cmd = { "ConformInfo" },
        keys = {
            {
                "<leader>f",
                function()
                    local progress = require("fidget.progress")
                    local handle = progress.handle.create({
                        title = "Formatting",
                        lsp_client = { name = "confirm.nvim" },
                        percentage = 0,
                    })
                    require("conform").format({ async = true, lsp_fallback = true }, function(err)
                        handle:finish()
                    end)
                end,
                mode = "",
                desc = "Format buffer",
                silent = true,
            },
        },
        opts = {
            formatters_by_ft = {
                fish = { "fish_indent" },
                graphql = { "prettier" },
                javascript = { "prettier" },
                json = { "jq" },
                lua = { "stylua" },
                markdown = { "mdformat" },
                python = { "black", "ruff_format" },
                rust = { "rustfmt" },
                svelte = { "prettier" },
                typescript = { "prettier" },
            },
        },
        init = function()
            vim.o.formatexpr = "v:lua.require'conform'.formatexpr()"
        end,
    },
    {
        "mfussenegger/nvim-lint",
        event = { "BufWritePre" },
        init = function()
            require("lint").linters_by_ft = {
                fish = { "fish", "cspell" },
                javascript = { "eslint", "cspell" },
                lua = { "cspell" },
                markdown = { "vale", "cspell" },
                python = { "ruff", "mypy", "cspell" },
                rust = { "cspell" },
                yaml = { "yamllint" },
            }
            vim.api.nvim_create_autocmd({ "BufWritePost" }, {
                callback = function()
                    local progress = require("fidget.progress")
                    local handle = progress.handle.create({
                        title = "Linting",
                        lsp_client = { name = "nvim-lint" },
                        percentage = 0,
                    })
                    require("lint").try_lint()
                    handle:finish()
                end,
            })
        end,
    },

    -- Lua helper library
    { "nvim-lua/plenary.nvim", lazy = true },

    -- Lua Fuzzy Finder
    {
        "nvim-telescope/telescope.nvim",
        keys = {
            { "<leader>/a", "<cmd>Telescope lsp_code_actions<cr>", silent = true },
            { "<leader>/b", "<cmd>Telescope buffers<cr>", silent = true },
            { "<leader>/e", "<cmd>Telescope loclist<cr>", silent = true },
            { "<leader>/f", "<cmd>Telescope find_files<cr>", silent = true },
            { "<leader>/g", "<cmd>Telescope live_grep<cr>", silent = true },
            { "<leader>/h", "<cmd>Telescope help_tags<cr>", silent = true },
            { "<leader>/r", "<cmd>Telescope registers<cr>", silent = true },
            { "<leader>/q", "<cmd>Telescope quickfix<cr>", silent = true },
        },
        config = true,
        dependencies = {
            "nvim-telescope/telescope-fzf-native.nvim",
        },
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
        keys = { { "<leader>gd", "<cmd>Gitsigns toggle_signs<cr>", silent = true } },
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
    {
        "echasnovski/mini.nvim",
        config = function()
            -- Better Around/Inside textobjects
            require("mini.ai").setup({ n_lines = 500 })
            -- Shortcuts for next and previous <quickfix|location>
            require("mini.bracketed").setup()
            -- Buffer removing (unshow, delete, wipeout), which saves window layout
            require("mini.bufremove").setup()
            -- Easy commenting in any language
            require("mini.comment").setup()
            -- Automatic read/write of session
            require("mini.sessions").setup()
            require("mini.splitjoin").setup()
            -- Easily change surrounding characters
            require("mini.surround").setup()
        end,
    },
    {
        "kristijanhusak/vim-dadbod-ui",
        dependencies = {
            { "tpope/vim-dadbod", lazy = true },
            { "kristijanhusak/vim-dadbod-completion", ft = { "sql", "mysql", "plsql" }, lazy = true },
        },
        cmd = {
            "DBUI",
            "DBUIToggle",
            "DBUIAddConnection",
            "DBUIFindBuffer",
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
