-- Set up notify before setting up noice
require("notify_conf")
require("noice").setup({
    presets = {
        bottom_search = true,
        command_palette = true,
    },
    lsp = {
        -- let fidget.nvim handle lsp progress since it does it per buffer
        progress = { enabled = false },
        -- override markdown rendering so that **cmp** and other plugins use **Treesitter**
        override = {
            ["vim.lsp.util.convert_input_to_markdown_lines"] = true,
            ["vim.lsp.util.stylize_markdown"] = true,
            ["cmp.entry.get_documentation"] = true,
        },
    },
    cmdline = {
        format = {
            cmdline = { icon = ">" },
            search_down = { icon = "▼/" },
            search_up = { icon = "▲/" },
            filter = { icon = "$" },
            lua = { icon = "☾" },
            help = { icon = "?" },
        },
    },
    routes = {
        -- Hide written message
        {
            filter = {
                event = "msg_show",
                kind = "",
                find = "written",
            },
            opts = { skip = true },
        },
    },
})
