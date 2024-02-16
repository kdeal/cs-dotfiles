local null_ls = require("null-ls")
null_ls.setup({
    sources = {
        -- Python sources
        null_ls.builtins.diagnostics.flake8,
        null_ls.builtins.diagnostics.mypy,
        -- Vim sources
        null_ls.builtins.diagnostics.vint,
        -- Yaml sources
        null_ls.builtins.diagnostics.yamllint,
        -- Markdown sources
        null_ls.builtins.code_actions.proselint,
    },
})
