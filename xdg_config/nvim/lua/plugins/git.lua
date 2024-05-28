return {
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
}
