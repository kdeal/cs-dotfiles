local nvim_lsp = require("lspconfig")

local on_attach = function(client, bufnr)
    local function buf_set_keymap(...)
        vim.api.nvim_buf_set_keymap(bufnr, ...)
    end
    local function buf_set_option(...)
        vim.api.nvim_buf_set_option(bufnr, ...)
    end

    local opts = { noremap = true, silent = true }
    buf_set_keymap("n", "gd", "<cmd>lua vim.lsp.buf.definition()<CR>", opts)
    buf_set_keymap("n", "gD", "<cmd>lua vim.lsp.buf.declaration()<CR>", opts)
    buf_set_keymap("n", "gi", "<cmd>lua vim.lsp.buf.implementation()<CR>", opts)
    buf_set_keymap("n", "gI", "<cmd>lua vim.lsp.buf.type_definition()<CR>", opts)
    buf_set_keymap("n", "gr", "<cmd>lua vim.lsp.buf.references()<CR>", opts)
    buf_set_keymap("n", "<leader>rn", "<cmd>lua require('rename_popup').rename()<CR>", opts)
    buf_set_keymap("n", "<space>ca", "<cmd>lua vim.lsp.buf.code_action()<CR>", opts)
end

-- Use a loop to conveniently both setup defined servers
-- and map buffer local keybindings when the language server attaches
local servers = {
    gopls = {},
    lua_ls = {},
    pyright = {
        python = {
            analysis = {
                typeCheckingMode = "off",
                diagnosticMode = "openFilesOnly",
            },
        },
    },
    rust_analyzer = {},
    svelte = {},
    tsserver = {},
}
local capabilities = require("cmp_nvim_lsp").default_capabilities()
for lsp, lsp_settings in pairs(servers) do
    settings = { on_attach = on_attach, capabilities = capabilities, settings = lsp_settings }
    nvim_lsp[lsp].setup(settings)
end
