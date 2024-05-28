return {
    -- Undo tree viewer
    {
        "mbbill/undotree",
        keys = {
            { "<leader>ou", "<cmd>UndotreeToggle<CR>", silent = true },
        },
        cmd = "UndotreeToggle",
        config = function()
            -- Move cursor into window when opening
            vim.g.undotree_SetFocusWhenToggle = 1
            -- Don't show diff by default
            vim.g.undotree_DiffAutoOpen = 0

            -- Change lines a little bit
            vim.g.undotree_TreeNodeShape = "◆"
            vim.g.undotree_TreeReturnShape = "╲"
            vim.g.undotree_TreeVertShape = "│"
            vim.g.undotree_TreeSplitShape = "╱"
        end,
    },
}
