return {
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
            require("neotest").setup({
                adapters = {
                    require("neotest-python")({}),
                    require("neotest-go"),
                },
                icons = {
                    running_animated = { "⠋", "⠙", "⠹", "⠸", "⠼", "⠴", "⠦", "⠧", "⠇", "⠏" },
                    passed = "✔",
                    running = "…",
                    failed = "✖",
                    skipped = "↷",
                    unknown = "🞅",
                },
                quickfix = {
                    open = false,
                },
            })

            -- Add background to the gutter icons
            vim.cmd([[
            highlight! link NeotestPassed GruvboxGreenSign
            highlight! link NeotestFailed GruvboxRedSign
            highlight! link NeotestRunning GruvboxPurpleSign
            highlight! link NeotestSkipped GruvboxBlueSign
            ]])

            nnoremap("<leader>op", '<cmd>lua require("neotest").summary.toggle()<cr>', { silent = true })

            nnoremap("<leader>rt", '<cmd>lua require("neotest").run.run({strategy = "dap"})<cr>', { silent = true })
            nnoremap("<leader>rf", '<cmd>lua require("neotest").run.run(vim.fn.expand("%"))<cr>', { silent = true })
        end,
    },
}
