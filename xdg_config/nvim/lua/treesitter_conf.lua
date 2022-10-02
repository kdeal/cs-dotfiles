vim.opt.foldmethod = 'expr'
vim.opt.foldexpr = 'nvim_treesitter#foldexpr()'

require'nvim-treesitter.configs'.setup {
    ensure_installed = {
        "comment",
        "css",
        "fish",
        "graphql",
        "go",
        "html",
        "javascript",
        "json",
        "lua",
        "python",
        "regex",
        "rust",
        "svelte",
        "toml",
        "tsx",
        "typescript",
        "yaml",
    },
    highlight = {
        enable = true,
    },
    indent = {
        enable = true,
        disable = {'python', 'javascript'},
    },
}
