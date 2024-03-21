local colors = require("nightfox.palette").load("nordfox")

_G.status_filetype = function()
    if vim.o.filetype ~= "" then
        return vim.o.filetype
    end
    return "no filetype"
end

_G.status_readonly = function()
    if vim.o.readonly then
        return "RO"
    end
    return ""
end

_G.status_modified = function()
    if vim.o.modified then
        return " ●"
    end
    return ""
end

_G.status_current_project = function()
    return vim.fn.fnamemodify(vim.loop.cwd(), ":t")
end

_G.diagnostics_statusline = function()
    local diagnostics = vim.diagnostic.get(0)
    local counts = {}
    for _, diagnostic in pairs(diagnostics) do
        local cur_count = counts[diagnostic.severity] or 0
        counts[diagnostic.severity] = cur_count + 1
    end

    local severity_symbol = {
        [vim.diagnostic.severity.ERROR] = "✘",
        [vim.diagnostic.severity.WARN] = "⚑",
        [vim.diagnostic.severity.INFO] = "ℹ",
        [vim.diagnostic.severity.HINT] = "🞇",
    }
    local status = ""
    for severity, count in pairs(counts) do
        local section = string.format(" %d %s", count, severity_symbol[severity])
        status = status .. section
    end
    if status ~= "" then
        status = status .. " "
    end
    return status
end

_G.status_record_status = function()
    local status_mode = require("noice").api.statusline.mode.get()
    if status_mode == nil or string.match(status_mode, "-- .+ --") then
        return ""
    else
        return status_mode
    end
end

-- Read-only
vim.api.nvim_set_hl(0, "User1", { fg = colors.red.base, bg = colors.bg0, ctermfg = 1, ctermbg = 10 })
-- filename
vim.api.nvim_set_hl(0, "User2", { fg = colors.fg2, bg = colors.bg0, ctermfg = 8, ctermbg = 10 })
-- Modified
vim.api.nvim_set_hl(0, "User3", { fg = colors.orange.base, bg = colors.bg0, bold = true, ctermfg = 166, ctermbg = 10 })
-- Linter
vim.api.nvim_set_hl(0, "User4", { fg = colors.black.base, bg = colors.red.base, ctermfg = 254, ctermbg = 1 })
-- Beginning/End
vim.api.nvim_set_hl(0, "User5", { fg = colors.fg, bg = colors.bg2, ctermfg = 254, ctermbg = 1 })

vim.o.statusline =
    "%5* %{v:lua.status_current_project()} %2* %{v:lua.status_record_status()}%<%=%{v:lua.status_filetype()} %4*%{v:lua.diagnostics_statusline()}%5* %l:%c %P "

vim.o.winbar = "%2* %f%h%q%3*%{v:lua.status_modified()}%2* %1*%{v:lua.status_readonly()}%2*"
