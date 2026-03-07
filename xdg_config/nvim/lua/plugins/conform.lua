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
            format_on_save = {
                lsp_format = "fallback",
                timeout_ms = 500,
            },
            formatters_by_ft = {
                css = { "oxfmt" },
                fish = { "fish_indent" },
                graphql = { "oxfmt" },
                hmtl = { "oxfmt" },
                javascript = { "oxfmt" },
                javascriptreact = { "oxfmt" },
                json = { "oxfmt" },
                jsonc = { "oxfmt" },
                json5 = { "oxfmt" },
                lua = { "stylua" },
                markdown = { "oxfmt" },
                python = { "ruff_format", "ruff_organize_imports" },
                rust = { "rustfmt" },
                templ = { "templ" },
                toml = { "oxfmt" },
                typescript = { "oxfmt" },
                typescriptreact = { "oxfmt" },
                yaml = { "oxfmt" },
            },
        },
        init = function()
            vim.o.formatexpr = "v:lua.require'conform'.formatexpr()"
        end,
    },
}
