return {
    -- Tree sitter based syntax highlighting
    {
        "nvim-treesitter/nvim-treesitter",
        build = function()
            require("nvim-treesitter.install").update({ with_sync = true })
        end,
        opts = {
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
            },
        },
        config = function(_, opts)
            require("nvim-treesitter.configs").setup(opts)
        end,
    },
}
