return {
    -- Config for neovim language servers
    {
        "neovim/nvim-lspconfig",
        dependencies = { "saghen/blink.cmp" },
        event = "BufReadPre",
        config = function()
            local on_attach = function(client, bufnr)
                local function buf_set_keymap(mode, lhs, rhs, opts)
                    vim.keymap.set(mode, lhs, rhs, vim.tbl_extend("force", { buffer = bufnr }, opts or {}))
                end

                local opts = { silent = true }
                buf_set_keymap("n", "gd", "<C-]>", opts)
                buf_set_keymap("n", "gD", vim.lsp.buf.declaration, opts)
                buf_set_keymap("n", "grI", vim.lsp.buf.type_definition, opts)
                buf_set_keymap("n", "grn", function()
                    require("rename_popup").rename()
                end, opts)
                -- These are the default on nightly
                buf_set_keymap("n", "grr", vim.lsp.buf.references, opts)
                buf_set_keymap("n", "gra", vim.lsp.buf.code_action, opts)
                buf_set_keymap("v", "gra", vim.lsp.buf.code_action, opts)
                buf_set_keymap("n", "gri", vim.lsp.buf.implementation, opts)
                buf_set_keymap("n", "gO", vim.lsp.buf.document_symbol, opts)
                buf_set_keymap("i", "<C-s>", vim.lsp.buf.signature_help, opts)
            end

            -- Use a loop to conveniently both setup defined servers
            -- and map buffer local keybindings when the language server attaches
            local servers = {
                copilot = {},
                cssls = {},
                gopls = {
                    gopls = {
                        analyses = {
                            shadow = true,
                        },
                        staticcheck = true,
                    },
                },
                html = {},
                lua_ls = {},
                ty = {},
                ruff = {},
                rust_analyzer = {},
                svelte = {},
                tailwindcss = {},
                templ = {},
                ts_ls = {},
            }
            local capabilities = require("blink.cmp").get_lsp_capabilities()
            for lsp, lsp_settings in pairs(servers) do
                local settings = { on_attach = on_attach, capabilities = capabilities, settings = lsp_settings }
                vim.lsp.enable(lsp)
                vim.lsp.config(lsp, settings)
            end
        end,
    },
    {
        "folke/lazydev.nvim",
        opts = {
            -- This is the same as the default, but also checks if the
            -- root_dir is my dotfiles repo
            ---@type boolean|(fun(client:vim.lsp.Client):boolean?)
            enabled = function(client)
                if vim.g.lazydev_enabled ~= nil then
                    return vim.g.lazydev_enabled
                end

                if not client.root_dir then
                    return false
                end

                if string.match(client.root_dir, "cs%-dotfiles$") then
                    return true
                end

                if vim.uv.fs_stat(client.root_dir .. "/lua") then
                    return true
                end

                return false
            end,
        },
        ft = "lua",
    },

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
}
