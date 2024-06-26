return {
    {
        "L3MON4D3/LuaSnip",
        event = "InsertEnter",
        config = function()
            -- This will enable loading snippets from the snippets directory
            require("luasnip.loaders.from_vscode").lazy_load({ paths = { vim.fn.stdpath("config") .. "/snippets" } })

            inoremap("<C-F>", '<cmd>lua require("luasnip").jump(1)<CR>', { silent = true })
            inoremap("<C-B>", '<cmd>lua require("luasnip").jump(-1)<CR>', { silent = true })
            snoremap("<C-F>", '<cmd>lua require("luasnip").jump(1)<CR>', { silent = true })
            snoremap("<C-B>", '<cmd>lua require("luasnip").jump(-1)<CR>', { silent = true })
        end,
    },
}
