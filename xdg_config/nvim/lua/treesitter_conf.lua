require("nvim-treesitter.configs").setup({
    ensure_installed = {
        "bash",
        "comment",
        "css",
        "diff",
        "fish",
        "gitcommit",
        "git_rebase",
        "graphql",
        "go",
        "html",
        "ini",
        "javascript",
        "json",
        "lua",
        "make",
        "markdown",
        "markdown_inline",
        "python",
        "regex",
        "rust",
        "svelte",
        "terraform",
        "toml",
        "tsx",
        "typescript",
        "vimdoc",
        "yaml",
    },
    highlight = {
        enable = true,
    },
    indent = {
        enable = true,
        disable = { "python", "javascript" },
    },
})