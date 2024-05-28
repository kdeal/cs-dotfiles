return {
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
}
