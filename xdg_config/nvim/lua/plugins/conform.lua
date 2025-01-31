return {
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
                python = { "ruff_format", "ruff_organize_imports" },
                rust = { "rustfmt" },
                svelte = { "prettier" },
                typescript = { "prettier" },
            },
        },
        init = function()
            vim.o.formatexpr = "v:lua.require'conform'.formatexpr()"
        end,
    },
}
