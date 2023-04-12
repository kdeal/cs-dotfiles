-- Automatically generated packer.nvim plugin loader code

if vim.api.nvim_call_function("has", { "nvim-0.5" }) ~= 1 then
    vim.api.nvim_command('echohl WarningMsg | echom "Invalid Neovim version for packer.nvim! | echohl None"')
    return
end

vim.api.nvim_command("packadd packer.nvim")

local no_errors, error_msg = pcall(function()
    _G._packer = _G._packer or {}
    _G._packer.inside_compile = true

    local time
    local profile_info
    local should_profile = false
    if should_profile then
        local hrtime = vim.loop.hrtime
        profile_info = {}
        time = function(chunk, start)
            if start then
                profile_info[chunk] = hrtime()
            else
                profile_info[chunk] = (hrtime() - profile_info[chunk]) / 1e6
            end
        end
    else
        time = function(chunk, start) end
    end

    local function save_profiles(threshold)
        local sorted_times = {}
        for chunk_name, time_taken in pairs(profile_info) do
            sorted_times[#sorted_times + 1] = { chunk_name, time_taken }
        end
        table.sort(sorted_times, function(a, b)
            return a[2] > b[2]
        end)
        local results = {}
        for i, elem in ipairs(sorted_times) do
            if not threshold or threshold and elem[2] > threshold then
                results[i] = elem[1] .. " took " .. elem[2] .. "ms"
            end
        end
        if threshold then
            table.insert(results, "(Only showing plugins that took longer than " .. threshold .. " ms " .. "to load)")
        end

        _G._packer.profile_output = results
    end

    time([[Luarocks path setup]], true)
    local package_path_str =
        "/home/codespace/.cache/nvim/packer_hererocks/2.1.0-beta3/share/lua/5.1/?.lua;/home/codespace/.cache/nvim/packer_hererocks/2.1.0-beta3/share/lua/5.1/?/init.lua;/home/codespace/.cache/nvim/packer_hererocks/2.1.0-beta3/lib/luarocks/rocks-5.1/?.lua;/home/codespace/.cache/nvim/packer_hererocks/2.1.0-beta3/lib/luarocks/rocks-5.1/?/init.lua"
    local install_cpath_pattern = "/home/codespace/.cache/nvim/packer_hererocks/2.1.0-beta3/lib/lua/5.1/?.so"
    if not string.find(package.path, package_path_str, 1, true) then
        package.path = package.path .. ";" .. package_path_str
    end

    if not string.find(package.cpath, install_cpath_pattern, 1, true) then
        package.cpath = package.cpath .. ";" .. install_cpath_pattern
    end

    time([[Luarocks path setup]], false)
    time([[try_loadstring definition]], true)
    local function try_loadstring(s, component, name)
        local success, result = pcall(loadstring(s), name, _G.packer_plugins[name])
        if not success then
            vim.schedule(function()
                vim.api.nvim_notify(
                    "packer.nvim: Error running " .. component .. " for " .. name .. ": " .. result,
                    vim.log.levels.ERROR,
                    {}
                )
            end)
        end
        return result
    end

    time([[try_loadstring definition]], false)
    time([[Defining packer_plugins]], true)
    _G.packer_plugins = {
        LuaSnip = {
            config = { "\27LJ\2\n,\0\0\3\0\2\0\0046\0\0\0'\2\1\0B\0\2\1K\0\1\0\17luasnip_conf\frequire\0" },
            loaded = true,
            path = "/home/codespace/.local/share/nvim/site/pack/packer/start/LuaSnip",
            url = "https://github.com/L3MON4D3/LuaSnip",
        },
        ["cmp-buffer"] = {
            loaded = true,
            path = "/home/codespace/.local/share/nvim/site/pack/packer/start/cmp-buffer",
            url = "https://github.com/hrsh7th/cmp-buffer",
        },
        ["cmp-nvim-lsp"] = {
            loaded = true,
            path = "/home/codespace/.local/share/nvim/site/pack/packer/start/cmp-nvim-lsp",
            url = "https://github.com/hrsh7th/cmp-nvim-lsp",
        },
        ["cmp-path"] = {
            loaded = true,
            path = "/home/codespace/.local/share/nvim/site/pack/packer/start/cmp-path",
            url = "https://github.com/hrsh7th/cmp-path",
        },
        cmp_luasnip = {
            loaded = true,
            path = "/home/codespace/.local/share/nvim/site/pack/packer/start/cmp_luasnip",
            url = "https://github.com/saadparwaiz1/cmp_luasnip",
        },
        ["fidget.nvim"] = {
            config = { "\27LJ\2\n+\0\0\3\0\2\0\0046\0\0\0'\2\1\0B\0\2\1K\0\1\0\16fidget_conf\frequire\0" },
            loaded = true,
            path = "/home/codespace/.local/share/nvim/site/pack/packer/start/fidget.nvim",
            url = "https://github.com/j-hui/fidget.nvim",
        },
        fzf = {
            loaded = true,
            path = "/home/codespace/.local/share/nvim/site/pack/packer/start/fzf",
            url = "https://github.com/junegunn/fzf",
        },
        ["gitsigns.nvim"] = {
            config = { "\27LJ\2\n-\0\0\3\0\2\0\0046\0\0\0'\2\1\0B\0\2\1K\0\1\0\18gitsigns_conf\frequire\0" },
            loaded = true,
            path = "/home/codespace/.local/share/nvim/site/pack/packer/start/gitsigns.nvim",
            url = "https://github.com/lewis6991/gitsigns.nvim",
        },
        ["goyo.vim"] = {
            loaded = true,
            path = "/home/codespace/.local/share/nvim/site/pack/packer/start/goyo.vim",
            url = "https://github.com/junegunn/goyo.vim",
        },
        gruvbox = {
            loaded = true,
            path = "/home/codespace/.local/share/nvim/site/pack/packer/start/gruvbox",
            url = "https://github.com/morhetz/gruvbox",
        },
        ["indent-blankline.nvim"] = {
            config = { "\27LJ\2\n+\0\0\3\0\2\0\0046\0\0\0'\2\1\0B\0\2\1K\0\1\0\16indent_conf\frequire\0" },
            loaded = true,
            path = "/home/codespace/.local/share/nvim/site/pack/packer/start/indent-blankline.nvim",
            url = "https://github.com/lukas-reineke/indent-blankline.nvim",
        },
        neotest = {
            config = { "\27LJ\2\n,\0\0\3\0\2\0\0046\0\0\0'\2\1\0B\0\2\1K\0\1\0\17neotest_conf\frequire\0" },
            loaded = true,
            path = "/home/codespace/.local/share/nvim/site/pack/packer/start/neotest",
            url = "https://github.com/nvim-neotest/neotest",
        },
        ["neotest-go"] = {
            loaded = true,
            path = "/home/codespace/.local/share/nvim/site/pack/packer/start/neotest-go",
            url = "https://github.com/nvim-neotest/neotest-go",
        },
        ["neotest-python"] = {
            loaded = true,
            path = "/home/codespace/.local/share/nvim/site/pack/packer/start/neotest-python",
            url = "https://github.com/nvim-neotest/neotest-python",
        },
        ["noice.nvim"] = {
            config = { "\27LJ\2\n*\0\0\3\0\2\0\0046\0\0\0'\2\1\0B\0\2\1K\0\1\0\15noice_conf\frequire\0" },
            loaded = true,
            path = "/home/codespace/.local/share/nvim/site/pack/packer/start/noice.nvim",
            url = "https://github.com/folke/noice.nvim",
        },
        ["nui.nvim"] = {
            loaded = true,
            path = "/home/codespace/.local/share/nvim/site/pack/packer/start/nui.nvim",
            url = "https://github.com/MunifTanjim/nui.nvim",
        },
        ["null-ls.nvim"] = {
            config = { "\27LJ\2\n,\0\0\3\0\2\0\0046\0\0\0'\2\1\0B\0\2\1K\0\1\0\17null_ls_conf\frequire\0" },
            loaded = true,
            path = "/home/codespace/.local/share/nvim/site/pack/packer/start/null-ls.nvim",
            url = "https://github.com/jose-elias-alvarez/null-ls.nvim",
        },
        ["nvim-cmp"] = {
            config = { "\27LJ\2\n(\0\0\3\0\2\0\0046\0\0\0'\2\1\0B\0\2\1K\0\1\0\rcmp_conf\frequire\0" },
            loaded = true,
            path = "/home/codespace/.local/share/nvim/site/pack/packer/start/nvim-cmp",
            url = "https://github.com/hrsh7th/nvim-cmp",
        },
        ["nvim-dap"] = {
            config = { "\27LJ\2\n(\0\0\3\0\2\0\0046\0\0\0'\2\1\0B\0\2\1K\0\1\0\rdap_conf\frequire\0" },
            loaded = true,
            path = "/home/codespace/.local/share/nvim/site/pack/packer/start/nvim-dap",
            url = "https://github.com/mfussenegger/nvim-dap",
        },
        ["nvim-dap-python"] = {
            config = { "\27LJ\2\n/\0\0\3\0\2\0\0046\0\0\0'\2\1\0B\0\2\1K\0\1\0\20dap_python_conf\frequire\0" },
            loaded = true,
            path = "/home/codespace/.local/share/nvim/site/pack/packer/start/nvim-dap-python",
            url = "https://github.com/mfussenegger/nvim-dap-python",
        },
        ["nvim-dap-ui"] = {
            config = { "\27LJ\2\n*\0\0\3\0\2\0\0046\0\0\0'\2\1\0B\0\2\1K\0\1\0\15dapui_conf\frequire\0" },
            loaded = true,
            path = "/home/codespace/.local/share/nvim/site/pack/packer/start/nvim-dap-ui",
            url = "https://github.com/rcarriga/nvim-dap-ui",
        },
        ["nvim-lspconfig"] = {
            config = { "\27LJ\2\n(\0\0\3\0\2\0\0046\0\0\0'\2\1\0B\0\2\1K\0\1\0\rlsp_conf\frequire\0" },
            loaded = true,
            path = "/home/codespace/.local/share/nvim/site/pack/packer/start/nvim-lspconfig",
            url = "https://github.com/neovim/nvim-lspconfig",
        },
        ["nvim-treesitter"] = {
            config = { "\27LJ\2\n/\0\0\3\0\2\0\0046\0\0\0'\2\1\0B\0\2\1K\0\1\0\20treesitter_conf\frequire\0" },
            loaded = true,
            path = "/home/codespace/.local/share/nvim/site/pack/packer/start/nvim-treesitter",
            url = "https://github.com/nvim-treesitter/nvim-treesitter",
        },
        ["packer.nvim"] = {
            loaded = true,
            path = "/home/codespace/.local/share/nvim/site/pack/packer/start/packer.nvim",
            url = "https://github.com/wbthomason/packer.nvim",
        },
        ["plenary.nvim"] = {
            loaded = true,
            path = "/home/codespace/.local/share/nvim/site/pack/packer/start/plenary.nvim",
            url = "https://github.com/nvim-lua/plenary.nvim",
        },
        ["requirements.txt.vim"] = {
            loaded = true,
            path = "/home/codespace/.local/share/nvim/site/pack/packer/start/requirements.txt.vim",
            url = "https://github.com/raimon49/requirements.txt.vim",
        },
        ["sideways.vim"] = {
            commands = { "SidewaysLeft", "SidewaysRight" },
            loaded = false,
            needs_bufread = true,
            only_cond = false,
            path = "/home/codespace/.local/share/nvim/site/pack/packer/opt/sideways.vim",
            url = "https://github.com/AndrewRadev/sideways.vim",
        },
        ["splitjoin.vim"] = {
            loaded = true,
            path = "/home/codespace/.local/share/nvim/site/pack/packer/start/splitjoin.vim",
            url = "https://github.com/AndrewRadev/splitjoin.vim",
        },
        ["telescope-fzf-native.nvim"] = {
            loaded = true,
            path = "/home/codespace/.local/share/nvim/site/pack/packer/start/telescope-fzf-native.nvim",
            url = "https://github.com/nvim-telescope/telescope-fzf-native.nvim",
        },
        ["telescope.nvim"] = {
            config = { "\27LJ\2\n.\0\0\3\0\2\0\0046\0\0\0'\2\1\0B\0\2\1K\0\1\0\19telescope_conf\frequire\0" },
            loaded = true,
            path = "/home/codespace/.local/share/nvim/site/pack/packer/start/telescope.nvim",
            url = "https://github.com/nvim-telescope/telescope.nvim",
        },
        undotree = {
            commands = { "UndotreeToggle" },
            loaded = false,
            needs_bufread = false,
            only_cond = false,
            path = "/home/codespace/.local/share/nvim/site/pack/packer/opt/undotree",
            url = "https://github.com/mbbill/undotree",
        },
        ["vim-commentary"] = {
            loaded = true,
            path = "/home/codespace/.local/share/nvim/site/pack/packer/start/vim-commentary",
            url = "https://github.com/tpope/vim-commentary",
        },
        ["vim-eunuch"] = {
            commands = { "Delete", "Unlink", "Move", "Rename", "Chmod", "Mkdir", "SudoWrite", "SudoEdit" },
            loaded = false,
            needs_bufread = false,
            only_cond = false,
            path = "/home/codespace/.local/share/nvim/site/pack/packer/opt/vim-eunuch",
            url = "https://github.com/tpope/vim-eunuch",
        },
        ["vim-fugitive"] = {
            config = { "\27LJ\2\n-\0\0\3\0\2\0\0046\0\0\0'\2\1\0B\0\2\1K\0\1\0\18fugitive_conf\frequire\0" },
            loaded = true,
            path = "/home/codespace/.local/share/nvim/site/pack/packer/start/vim-fugitive",
            url = "https://github.com/tpope/vim-fugitive",
        },
        ["vim-javascript"] = {
            loaded = true,
            path = "/home/codespace/.local/share/nvim/site/pack/packer/start/vim-javascript",
            url = "https://github.com/pangloss/vim-javascript",
        },
        ["vim-polyglot"] = {
            loaded = true,
            needs_bufread = true,
            path = "/home/codespace/.local/share/nvim/site/pack/packer/opt/vim-polyglot",
            url = "https://github.com/sheerun/vim-polyglot",
        },
        ["vim-python-pep8-indent"] = {
            loaded = true,
            path = "/home/codespace/.local/share/nvim/site/pack/packer/start/vim-python-pep8-indent",
            url = "https://github.com/Vimjas/vim-python-pep8-indent",
        },
        ["vim-repeat"] = {
            loaded = true,
            path = "/home/codespace/.local/share/nvim/site/pack/packer/start/vim-repeat",
            url = "https://github.com/tpope/vim-repeat",
        },
        ["vim-rooter"] = {
            loaded = true,
            path = "/home/codespace/.local/share/nvim/site/pack/packer/start/vim-rooter",
            url = "https://github.com/airblade/vim-rooter",
        },
        ["vim-unimpaired"] = {
            loaded = true,
            path = "/home/codespace/.local/share/nvim/site/pack/packer/start/vim-unimpaired",
            url = "https://github.com/tpope/vim-unimpaired",
        },
        ["vim-visual-star-search"] = {
            loaded = true,
            path = "/home/codespace/.local/share/nvim/site/pack/packer/start/vim-visual-star-search",
            url = "https://github.com/bronson/vim-visual-star-search",
        },
    }

    time([[Defining packer_plugins]], false)
    -- Setup for: vim-polyglot
    time([[Setup for vim-polyglot]], true)
    try_loadstring(
        "\27LJ\2\n>\0\0\2\0\4\0\0056\0\0\0009\0\1\0005\1\3\0=\1\2\0K\0\1\0\1\2\0\0\vpython\22polyglot_disabled\6g\bvim\0",
        "setup",
        "vim-polyglot"
    )
    time([[Setup for vim-polyglot]], false)
    time([[packadd for vim-polyglot]], true)
    vim.cmd([[packadd vim-polyglot]])
    time([[packadd for vim-polyglot]], false)
    -- Config for: fidget.nvim
    time([[Config for fidget.nvim]], true)
    try_loadstring(
        "\27LJ\2\n+\0\0\3\0\2\0\0046\0\0\0'\2\1\0B\0\2\1K\0\1\0\16fidget_conf\frequire\0",
        "config",
        "fidget.nvim"
    )
    time([[Config for fidget.nvim]], false)
    -- Config for: indent-blankline.nvim
    time([[Config for indent-blankline.nvim]], true)
    try_loadstring(
        "\27LJ\2\n+\0\0\3\0\2\0\0046\0\0\0'\2\1\0B\0\2\1K\0\1\0\16indent_conf\frequire\0",
        "config",
        "indent-blankline.nvim"
    )
    time([[Config for indent-blankline.nvim]], false)
    -- Config for: nvim-dap-python
    time([[Config for nvim-dap-python]], true)
    try_loadstring(
        "\27LJ\2\n/\0\0\3\0\2\0\0046\0\0\0'\2\1\0B\0\2\1K\0\1\0\20dap_python_conf\frequire\0",
        "config",
        "nvim-dap-python"
    )
    time([[Config for nvim-dap-python]], false)
    -- Config for: nvim-lspconfig
    time([[Config for nvim-lspconfig]], true)
    try_loadstring(
        "\27LJ\2\n(\0\0\3\0\2\0\0046\0\0\0'\2\1\0B\0\2\1K\0\1\0\rlsp_conf\frequire\0",
        "config",
        "nvim-lspconfig"
    )
    time([[Config for nvim-lspconfig]], false)
    -- Config for: neotest
    time([[Config for neotest]], true)
    try_loadstring(
        "\27LJ\2\n,\0\0\3\0\2\0\0046\0\0\0'\2\1\0B\0\2\1K\0\1\0\17neotest_conf\frequire\0",
        "config",
        "neotest"
    )
    time([[Config for neotest]], false)
    -- Config for: null-ls.nvim
    time([[Config for null-ls.nvim]], true)
    try_loadstring(
        "\27LJ\2\n,\0\0\3\0\2\0\0046\0\0\0'\2\1\0B\0\2\1K\0\1\0\17null_ls_conf\frequire\0",
        "config",
        "null-ls.nvim"
    )
    time([[Config for null-ls.nvim]], false)
    -- Config for: gitsigns.nvim
    time([[Config for gitsigns.nvim]], true)
    try_loadstring(
        "\27LJ\2\n-\0\0\3\0\2\0\0046\0\0\0'\2\1\0B\0\2\1K\0\1\0\18gitsigns_conf\frequire\0",
        "config",
        "gitsigns.nvim"
    )
    time([[Config for gitsigns.nvim]], false)
    -- Config for: LuaSnip
    time([[Config for LuaSnip]], true)
    try_loadstring(
        "\27LJ\2\n,\0\0\3\0\2\0\0046\0\0\0'\2\1\0B\0\2\1K\0\1\0\17luasnip_conf\frequire\0",
        "config",
        "LuaSnip"
    )
    time([[Config for LuaSnip]], false)
    -- Config for: telescope.nvim
    time([[Config for telescope.nvim]], true)
    try_loadstring(
        "\27LJ\2\n.\0\0\3\0\2\0\0046\0\0\0'\2\1\0B\0\2\1K\0\1\0\19telescope_conf\frequire\0",
        "config",
        "telescope.nvim"
    )
    time([[Config for telescope.nvim]], false)
    -- Config for: nvim-cmp
    time([[Config for nvim-cmp]], true)
    try_loadstring("\27LJ\2\n(\0\0\3\0\2\0\0046\0\0\0'\2\1\0B\0\2\1K\0\1\0\rcmp_conf\frequire\0", "config", "nvim-cmp")
    time([[Config for nvim-cmp]], false)
    -- Config for: nvim-dap-ui
    time([[Config for nvim-dap-ui]], true)
    try_loadstring(
        "\27LJ\2\n*\0\0\3\0\2\0\0046\0\0\0'\2\1\0B\0\2\1K\0\1\0\15dapui_conf\frequire\0",
        "config",
        "nvim-dap-ui"
    )
    time([[Config for nvim-dap-ui]], false)
    -- Config for: vim-fugitive
    time([[Config for vim-fugitive]], true)
    try_loadstring(
        "\27LJ\2\n-\0\0\3\0\2\0\0046\0\0\0'\2\1\0B\0\2\1K\0\1\0\18fugitive_conf\frequire\0",
        "config",
        "vim-fugitive"
    )
    time([[Config for vim-fugitive]], false)
    -- Config for: nvim-treesitter
    time([[Config for nvim-treesitter]], true)
    try_loadstring(
        "\27LJ\2\n/\0\0\3\0\2\0\0046\0\0\0'\2\1\0B\0\2\1K\0\1\0\20treesitter_conf\frequire\0",
        "config",
        "nvim-treesitter"
    )
    time([[Config for nvim-treesitter]], false)
    -- Config for: nvim-dap
    time([[Config for nvim-dap]], true)
    try_loadstring("\27LJ\2\n(\0\0\3\0\2\0\0046\0\0\0'\2\1\0B\0\2\1K\0\1\0\rdap_conf\frequire\0", "config", "nvim-dap")
    time([[Config for nvim-dap]], false)
    -- Config for: noice.nvim
    time([[Config for noice.nvim]], true)
    try_loadstring(
        "\27LJ\2\n*\0\0\3\0\2\0\0046\0\0\0'\2\1\0B\0\2\1K\0\1\0\15noice_conf\frequire\0",
        "config",
        "noice.nvim"
    )
    time([[Config for noice.nvim]], false)

    -- Command lazy-loads
    time([[Defining lazy-load commands]], true)
    pcall(vim.api.nvim_create_user_command, "Delete", function(cmdargs)
        require("packer.load")({ "vim-eunuch" }, {
            cmd = "Delete",
            l1 = cmdargs.line1,
            l2 = cmdargs.line2,
            bang = cmdargs.bang,
            args = cmdargs.args,
            mods = cmdargs.mods,
        }, _G.packer_plugins)
    end, {
        nargs = "*",
        range = true,
        bang = true,
        complete = function()
            require("packer.load")({ "vim-eunuch" }, {}, _G.packer_plugins)
            return vim.fn.getcompletion("Delete ", "cmdline")
        end,
    })
    pcall(vim.api.nvim_create_user_command, "Unlink", function(cmdargs)
        require("packer.load")({ "vim-eunuch" }, {
            cmd = "Unlink",
            l1 = cmdargs.line1,
            l2 = cmdargs.line2,
            bang = cmdargs.bang,
            args = cmdargs.args,
            mods = cmdargs.mods,
        }, _G.packer_plugins)
    end, {
        nargs = "*",
        range = true,
        bang = true,
        complete = function()
            require("packer.load")({ "vim-eunuch" }, {}, _G.packer_plugins)
            return vim.fn.getcompletion("Unlink ", "cmdline")
        end,
    })
    pcall(vim.api.nvim_create_user_command, "Move", function(cmdargs)
        require("packer.load")({ "vim-eunuch" }, {
            cmd = "Move",
            l1 = cmdargs.line1,
            l2 = cmdargs.line2,
            bang = cmdargs.bang,
            args = cmdargs.args,
            mods = cmdargs.mods,
        }, _G.packer_plugins)
    end, {
        nargs = "*",
        range = true,
        bang = true,
        complete = function()
            require("packer.load")({ "vim-eunuch" }, {}, _G.packer_plugins)
            return vim.fn.getcompletion("Move ", "cmdline")
        end,
    })
    pcall(vim.api.nvim_create_user_command, "Rename", function(cmdargs)
        require("packer.load")({ "vim-eunuch" }, {
            cmd = "Rename",
            l1 = cmdargs.line1,
            l2 = cmdargs.line2,
            bang = cmdargs.bang,
            args = cmdargs.args,
            mods = cmdargs.mods,
        }, _G.packer_plugins)
    end, {
        nargs = "*",
        range = true,
        bang = true,
        complete = function()
            require("packer.load")({ "vim-eunuch" }, {}, _G.packer_plugins)
            return vim.fn.getcompletion("Rename ", "cmdline")
        end,
    })
    pcall(vim.api.nvim_create_user_command, "Chmod", function(cmdargs)
        require("packer.load")({ "vim-eunuch" }, {
            cmd = "Chmod",
            l1 = cmdargs.line1,
            l2 = cmdargs.line2,
            bang = cmdargs.bang,
            args = cmdargs.args,
            mods = cmdargs.mods,
        }, _G.packer_plugins)
    end, {
        nargs = "*",
        range = true,
        bang = true,
        complete = function()
            require("packer.load")({ "vim-eunuch" }, {}, _G.packer_plugins)
            return vim.fn.getcompletion("Chmod ", "cmdline")
        end,
    })
    pcall(vim.api.nvim_create_user_command, "Mkdir", function(cmdargs)
        require("packer.load")({ "vim-eunuch" }, {
            cmd = "Mkdir",
            l1 = cmdargs.line1,
            l2 = cmdargs.line2,
            bang = cmdargs.bang,
            args = cmdargs.args,
            mods = cmdargs.mods,
        }, _G.packer_plugins)
    end, {
        nargs = "*",
        range = true,
        bang = true,
        complete = function()
            require("packer.load")({ "vim-eunuch" }, {}, _G.packer_plugins)
            return vim.fn.getcompletion("Mkdir ", "cmdline")
        end,
    })
    pcall(vim.api.nvim_create_user_command, "SudoWrite", function(cmdargs)
        require("packer.load")({ "vim-eunuch" }, {
            cmd = "SudoWrite",
            l1 = cmdargs.line1,
            l2 = cmdargs.line2,
            bang = cmdargs.bang,
            args = cmdargs.args,
            mods = cmdargs.mods,
        }, _G.packer_plugins)
    end, {
        nargs = "*",
        range = true,
        bang = true,
        complete = function()
            require("packer.load")({ "vim-eunuch" }, {}, _G.packer_plugins)
            return vim.fn.getcompletion("SudoWrite ", "cmdline")
        end,
    })
    pcall(vim.api.nvim_create_user_command, "SudoEdit", function(cmdargs)
        require("packer.load")({ "vim-eunuch" }, {
            cmd = "SudoEdit",
            l1 = cmdargs.line1,
            l2 = cmdargs.line2,
            bang = cmdargs.bang,
            args = cmdargs.args,
            mods = cmdargs.mods,
        }, _G.packer_plugins)
    end, {
        nargs = "*",
        range = true,
        bang = true,
        complete = function()
            require("packer.load")({ "vim-eunuch" }, {}, _G.packer_plugins)
            return vim.fn.getcompletion("SudoEdit ", "cmdline")
        end,
    })
    pcall(vim.api.nvim_create_user_command, "SidewaysRight", function(cmdargs)
        require("packer.load")({ "sideways.vim" }, {
            cmd = "SidewaysRight",
            l1 = cmdargs.line1,
            l2 = cmdargs.line2,
            bang = cmdargs.bang,
            args = cmdargs.args,
            mods = cmdargs.mods,
        }, _G.packer_plugins)
    end, {
        nargs = "*",
        range = true,
        bang = true,
        complete = function()
            require("packer.load")({ "sideways.vim" }, {}, _G.packer_plugins)
            return vim.fn.getcompletion("SidewaysRight ", "cmdline")
        end,
    })
    pcall(vim.api.nvim_create_user_command, "UndotreeToggle", function(cmdargs)
        require("packer.load")({ "undotree" }, {
            cmd = "UndotreeToggle",
            l1 = cmdargs.line1,
            l2 = cmdargs.line2,
            bang = cmdargs.bang,
            args = cmdargs.args,
            mods = cmdargs.mods,
        }, _G.packer_plugins)
    end, {
        nargs = "*",
        range = true,
        bang = true,
        complete = function()
            require("packer.load")({ "undotree" }, {}, _G.packer_plugins)
            return vim.fn.getcompletion("UndotreeToggle ", "cmdline")
        end,
    })
    pcall(vim.api.nvim_create_user_command, "SidewaysLeft", function(cmdargs)
        require("packer.load")({ "sideways.vim" }, {
            cmd = "SidewaysLeft",
            l1 = cmdargs.line1,
            l2 = cmdargs.line2,
            bang = cmdargs.bang,
            args = cmdargs.args,
            mods = cmdargs.mods,
        }, _G.packer_plugins)
    end, {
        nargs = "*",
        range = true,
        bang = true,
        complete = function()
            require("packer.load")({ "sideways.vim" }, {}, _G.packer_plugins)
            return vim.fn.getcompletion("SidewaysLeft ", "cmdline")
        end,
    })
    time([[Defining lazy-load commands]], false)

    _G._packer.inside_compile = false
    if _G._packer.needs_bufread == true then
        vim.cmd("doautocmd BufRead")
    end
    _G._packer.needs_bufread = false

    if should_profile then
        save_profiles()
    end
end)

if not no_errors then
    error_msg = error_msg:gsub('"', '\\"')
    vim.api.nvim_command(
        'echohl ErrorMsg | echom "Error in packer_compiled: '
            .. error_msg
            .. '" | echom "Please check your config for correctness" | echohl None'
    )
end
