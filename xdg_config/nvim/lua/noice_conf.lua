require("noice").setup({
    presets = {
        bottom_search = true,
        command_palette = true,
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
        -- Notification for recording macro
        {
            view = "notify",
            filter = { event = "msg_showmode" },
        },
    },
})
