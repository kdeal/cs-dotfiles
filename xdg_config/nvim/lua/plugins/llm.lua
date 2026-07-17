return {

    {
        "folke/sidekick.nvim",
        opts = {
            nes = { enabled = false },
        },
        keys = {
            {
                "<leader>aa",
                function()
                    require("sidekick.cli").toggle({ name = vim.g.sidekick_cli or "opencode", focus = true })
                end,
                desc = "Sidekick Toggle CLI",
            },
            {
                "<leader>at",
                function()
                    require("sidekick.cli").send({ msg = "{this}" })
                end,
                mode = { "x", "n" },
                desc = "Send This",
            },
            {
                "<leader>av",
                function()
                    require("sidekick.cli").send({ msg = "{selection}" })
                end,
                mode = { "x" },
                desc = "Send Visual Selection",
            },
            {
                "<leader>ap",
                function()
                    require("sidekick.cli").prompt()
                end,
                mode = { "n", "x" },
                desc = "Sidekick Select Prompt",
            },
        },
    },
}
