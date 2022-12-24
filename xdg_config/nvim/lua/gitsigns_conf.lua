require("gitsigns").setup({
    signcolumn = false,
})
noremap("<leader>gd", ":Gitsigns toggle_signs<CR>")
