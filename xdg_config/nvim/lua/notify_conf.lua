local render_base = require("notify.render.base")
local stages_util = require("notify.stages.util")

-- Similar to compact, but doesn't show the title
-- https://github.com/rcarriga/nvim-notify/blob/master/lua/notify/render/compact.lua
function subcompact_render(bufnr, notif, highlights)
    local namespace = render_base.namespace()
    local icon = notif.icon

    local prefix = string.format("%s |", icon)
    notif.message[1] = string.format("%s %s", prefix, notif.message[1])

    vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, notif.message)

    local icon_length = vim.str_utfindex(icon)
    local prefix_length = vim.str_utfindex(prefix)

    vim.api.nvim_buf_set_extmark(bufnr, namespace, 0, 0, {
        hl_group = highlights.icon,
        end_col = icon_length + 1,
        priority = 50,
    })
    vim.api.nvim_buf_set_extmark(bufnr, namespace, 0, icon_length + 1, {
        hl_group = highlights.title,
        end_col = prefix_length + 1,
        priority = 50,
    })
    vim.api.nvim_buf_set_extmark(bufnr, namespace, 0, prefix_length + 1, {
        hl_group = highlights.body,
        end_line = #notif.message,
        priority = 50,
    })
end

-- Same as static stages, but doesn't overlap bottom bar
-- https://github.com/rcarriga/nvim-notify/blob/master/lua/notify/stages/static.lua
local static_skip_winbar_stages = {
    function(state)
        local next_height = state.message.height + 2
        local next_row = stages_util.available_slot(state.open_windows, next_height, "bottom_up")
        if not next_row then
            return nil
        end
        return {
            relative = "editor",
            anchor = "NE",
            width = state.message.width,
            height = state.message.height,
            col = vim.opt.columns:get(),
            row = next_row - 1,
            border = "rounded",
            style = "minimal",
        }
    end,
    function()
        return {
            col = { vim.opt.columns:get() },
            time = true,
        }
    end,
}

require("notify").setup({
    render = subcompact_render,
    stages = static_skip_winbar_stages,
    icons = {
        DEBUG = "🞇",
        ERROR = "✘",
        INFO = " ℹ",
        TRACE = "✎",
        WARN = "⚑",
    },
    fps = 10,
    max_width = 50,
})
