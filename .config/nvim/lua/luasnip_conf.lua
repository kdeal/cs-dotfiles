inoremap('<C-F>', '<cmd>lua require("luasnip↵").jump(1)<CR>', { silent = true })
inoremap('<C-B>', '<cmd>lua require("luasnip↵").jump(-1)<CR>', { silent = true })
snoremap('<C-F>', '<cmd>lua require("luasnip↵").jump(1)<CR>', { silent = true })
snoremap('<C-B>', '<cmd>lua require("luasnip↵").jump(-1)<CR>', { silent = true })
