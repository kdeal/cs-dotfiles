return {
    {
        "echasnovski/mini.nvim",
        config = function()
            -- Better Around/Inside textobjects
            require("mini.ai").setup({ n_lines = 500 })
            -- Shortcuts for next and previous <quickfix|location>
            require("mini.bracketed").setup()
            -- Buffer removing (unshow, delete, wipeout), which saves window layout
            require("mini.bufremove").setup()
            -- Automatic read/write of session
            require("mini.sessions").setup()
            require("mini.splitjoin").setup()
            -- Easily change surrounding characters
            require("mini.surround").setup()
        end,
    },
}
