local null_ls = require("null-ls")
null_ls.setup({
    sources = {
        -- Fish sources
        null_ls.builtins.formatting.fish_indent,
        -- Go sources
        null_ls.builtins.formatting.gofmt,
        -- Javascript sources
        null_ls.builtins.formatting.prettier,
        -- Python sources
        null_ls.builtins.formatting.black,
        null_ls.builtins.diagnostics.flake8,
        null_ls.builtins.diagnostics.mypy,
        null_ls.builtins.formatting.reorder_python_imports,
        -- Rust sources
        -- Deal with edition
        null_ls.builtins.formatting.rustfmt,
        -- Vim sources
        null_ls.builtins.diagnostics.vint,
        -- Yaml sources
        null_ls.builtins.diagnostics.yamllint,
        -- Markdown sources
        null_ls.builtins.code_actions.proselint,
        -- Lua sources
        null_ls.builtins.formatting.stylua,
    },
})
