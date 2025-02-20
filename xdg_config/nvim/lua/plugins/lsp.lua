return {
    -- Config for neovim language servers
    {
        "neovim/nvim-lspconfig",
        dependencies = { "saghen/blink.cmp" },
        event = "BufReadPre",
        config = function()
            local nvim_lsp = require("lspconfig")

            local on_attach = function(client, bufnr)
                local function buf_set_keymap(...)
                    vim.api.nvim_buf_set_keymap(bufnr, ...)
                end
                local function buf_set_option(...)
                    vim.api.nvim_buf_set_option(bufnr, ...)
                end

                local opts = { noremap = true, silent = true }
                buf_set_keymap("n", "gd", "<C-]>", opts)
                buf_set_keymap("n", "gD", "<cmd>lua vim.lsp.buf.declaration()<CR>", opts)
                buf_set_keymap("n", "grI", "<cmd>lua vim.lsp.buf.type_definition()<CR>", opts)
                buf_set_keymap("n", "grn", "<cmd>lua require('rename_popup').rename()<CR>", opts)
                -- These are the default on nightly
                buf_set_keymap("n", "grr", "<cmd>lua vim.lsp.buf.references()<CR>", opts)
                buf_set_keymap("n", "gra", "<cmd>lua vim.lsp.buf.code_action()<CR>", opts)
                buf_set_keymap("v", "gra", "<cmd>lua vim.lsp.buf.code_action()<CR>", opts)
                buf_set_keymap("n", "gri", "<cmd>lua vim.lsp.buf.implementation()<CR>", opts)
                buf_set_keymap("n", "gO", "<cmd>vim.lsp.buf.document_symbol()<CR>", opts)
                buf_set_keymap("i", "<C-s>", "<cmd>lua vim.lsp.buf.signature_help()<CR>", opts)
            end

            -- Use a loop to conveniently both setup defined servers
            -- and map buffer local keybindings when the language server attaches
            local servers = {
                cssls = {},
                gopls = {},
                html = {},
                lua_ls = {},
                basedpyright = {
                    basedpyright = {
                        analysis = {
                            typeCheckingMode = "off",
                            diagnosticMode = "openFilesOnly",
                        },
                    },
                },
                ruff = {},
                rust_analyzer = {},
                svelte = {},
                tailwindcss = {},
                tsserver = {},
            }
            local capabilities = require("blink.cmp").get_lsp_capabilities()
            for lsp, lsp_settings in pairs(servers) do
                local settings = { on_attach = on_attach, capabilities = capabilities, settings = lsp_settings }
                nvim_lsp[lsp].setup(settings)
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
