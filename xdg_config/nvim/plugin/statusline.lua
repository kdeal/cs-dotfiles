local MiniStatusline = require("mini.statusline")

function filetype_display()
    if vim.o.filetype ~= "" then
        return vim.o.filetype
    end
    return "no filetype"
end

function readonly_display()
    if vim.o.readonly then
        return "RO"
    end
    return ""
end

function modified_display()
    if vim.o.modified then
        return " ●"
    end
    return ""
end

function current_project()
    return vim.fn.fnamemodify(vim.loop.cwd(), ":t")
end

function diagnostics_display()
    local diagnostic_counts = vim.diagnostic.count(0)

    local severity_symbol = {
        [vim.diagnostic.severity.ERROR] = "✘",
        [vim.diagnostic.severity.WARN] = "⚑",
        [vim.diagnostic.severity.INFO] = "ℹ",
        [vim.diagnostic.severity.HINT] = "🞇",
    }
    local status = ""
    for severity, count in pairs(diagnostic_counts) do
        local section = string.format(" %d %s", count, severity_symbol[severity])
        status = status .. section
    end
    if status ~= "" then
        status = status .. " "
    end
    return status
end

function record_status()
    local status_mode = require("noice").api.statusline.mode.get()
    if status_mode == nil or string.match(status_mode, "-- .+ --") then
        return ""
    else
        return status_mode
    end
end

function tab_position()
    local cur_tab = vim.fn.tabpagenr()
    local total_tabs = vim.fn.tabpagenr("$")
    return string.format("%d/%d", cur_tab, total_tabs)
end

_G.statusline_content = function()
    local search = MiniStatusline.section_searchcount({ trunc_width = 75 })
    return MiniStatusline.combine_groups({
        { hl = "StatusLineEnds", strings = { current_project() } },
        { hl = "StatusLineSecond", strings = { tab_position() } },
        { hl = "StatusLineCenter", strings = { record_status() } },
        "%<%=",
        { hl = "StatusLineCenter", strings = { filetype_display() } },
        { hl = "StatusLineDiagnostics", strings = { diagnostics_display() } },
        { hl = "StatusLineSecond", strings = { search } },
        { hl = "StatusLineEnds", strings = { "%S %l:%c %P " } },
    })
end

_G.winbar_content = function()
    return MiniStatusline.combine_groups({
        { hl = "StatusLineCenter", strings = { "%f%h%q" } },
        { hl = "StatusLineModified", strings = { modified_display() } },
        { hl = "StatusLineReadOnly", strings = { readonly_display() } },
    })
end

vim.o.showcmdloc = "statusline"
vim.o.statusline = "%{%v:lua.statusline_content()%}"
vim.o.winbar = "%{%v:lua.winbar_content()%}"
