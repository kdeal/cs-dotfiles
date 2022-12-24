-- telescope bindings
nnoremap("<leader>/a", ":Telescope lsp_code_actions<CR>", { silent = true })
nnoremap("<leader>/b", ":Telescope buffers<CR>", { silent = true })
nnoremap("<leader>/e", ":Telescope loclist<CR>", { silent = true })
nnoremap("<leader>/f", ":Telescope find_files<CR>", { silent = true })
nnoremap("<leader>/g", ":Telescope live_grep<CR>", { silent = true })
nnoremap("<leader>/h", ":Telescope help_tags<CR>", { silent = true })
nnoremap("<leader>/r", ":Telescope registers<CR>", { silent = true })
nnoremap("<leader>/q", ":Telescope quickfix<CR>", { silent = true })

require("telescope").setup({})
require("telescope").load_extension("fzf")
