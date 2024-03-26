local cmp = require("cmp")
cmp.setup({
    snippet = {
        expand = function(args)
            require("luasnip").lsp_expand(args.body)
        end,
    },
    mapping = cmp.mapping.preset.insert(),
    sources = cmp.config.sources({
        { name = "nvim_lsp" },
        { name = "luasnip" },
        { name = "buffer" },
        { name = "path" },
    }),
})

vim.api.nvim_create_autocmd({ "FileType" }, {
    desc = "Setup dadbod completion for sql file types",
    pattern = { "sql", "mysql", "plsql" },
    callback = function()
        require("cmp").setup.buffer({ sources = { { name = "vim-dadbod-completion" } } })
    end,
})
