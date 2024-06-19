return {
    -- Show tests in a side panel
    {
        "nvim-neotest/neotest",
        dependencies = {
            "nvim-lua/plenary.nvim",
            "nvim-neotest/nvim-nio",
            "nvim-treesitter/nvim-treesitter",
            -- This isn't really required, but is lang implementations for it
            "nvim-neotest/neotest-python",
        },
        config = function()
            require("neotest").setup({
                adapters = {
                    require("neotest-python")({}),
                },
                quickfix = {
                    open = false,
                },
            })

            nnoremap("<leader>op", '<cmd>lua require("neotest").summary.toggle()<cr>', { silent = true })

            nnoremap("<leader>rt", '<cmd>lua require("neotest").run.run({strategy = "dap"})<cr>', { silent = true })
            nnoremap("<leader>rf", '<cmd>lua require("neotest").run.run(vim.fn.expand("%"))<cr>', { silent = true })
        end,
    },
}
