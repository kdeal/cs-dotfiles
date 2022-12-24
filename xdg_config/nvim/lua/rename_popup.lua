local log = require("plenary.log").new({
    plugin = "rename_popup",
    level = "info",
})
local popup = require("plenary.popup")

local rename_popup = {}

-- Stores information for callback to use
rename_popup._window_to_metadata = {}

local function get_new_word(win_id)
    local buf_id = vim.api.nvim_win_get_buf(win_id)
    local buf_lines = vim.api.nvim_buf_get_lines(buf_id, 0, -1, false)
    if #buf_lines > 1 then
        log.warn("Popup buffer longer than 1 line, using last line")
    end
    return buf_lines[1]
end

-- Adjust the mode, so it is back to where it started
local function restore_mode(initial_mode)
    -- TODO: support other modes? not sure if it is possible
    local cur_mode = vim.api.nvim_get_mode().mode
    if not string.match(cur_mode, initial_mode) then
        if string.match("n", initial_mode) then
            vim.api.nvim_command("stopinsert")
            -- Shift cursor forward one because leaving insert mode
            -- moves you back one character
            local pos = vim.api.nvim_win_get_cursor(0)
            pos[2] = pos[2] + 1
            vim.api.nvim_win_set_cursor(0, pos)
        else
            vim.api.nvim_command("startinsert")
        end
    end
end

local function on_submit(win_id)
    local new_word = get_new_word(win_id)

    local callback_data = rename_popup._window_to_metadata[win_id]
    if callback_data then
        -- Switch back to initial window, so we can use builtin rename
        vim.api.nvim_set_current_win(callback_data.win_id)
        vim.lsp.buf.rename(new_word)

        restore_mode(callback_data.initial_mode)

        rename_popup._window_to_metadata[win_id] = nil
    else
        log.warn("No callback data, can't rename")
    end
end

local function popup_options()
    local col_add = 0
    local cursor = vim.api.nvim_win_get_cursor(0)
    if cursor[2] == 0 then
        col_add = 1
    end
    return {
        callback = on_submit,
        -- Position on the line after the cursor
        line = "cursor+2",
        col = "cursor+" .. col_add,
        border = true,

        -- Formatting related settings
        -- These characters make the border look nicer
        borderchars = { "─", "│", "─", "│", "╭", "╮", "╯", "╰" },
        borderhighlight = "RenamePopupBackground",
        highlight = "RenamePopupBackground",
        minheight = 1,
        minwidth = 30,
        wrap = false,
    }
end

local function configure_window(prompt_win_id)
    local buf_id = vim.api.nvim_win_get_buf(prompt_win_id)

    -- Start in popup in normal mode
    vim.api.nvim_command("stopinsert")

    vim.api.nvim_buf_set_keymap(
        buf_id,
        "i",
        "<CR>",
        '<cmd>lua require("plenary.popup").execute_callback(' .. buf_id .. ")<CR>",
        { noremap = true }
    )
    vim.api.nvim_buf_set_keymap(buf_id, "n", "<esc>", "<cmd>quit<CR>", { noremap = true })
end

function rename_popup.rename()
    local callback_data = {
        win_id = vim.api.nvim_get_current_win(),
        initial_mode = vim.api.nvim_get_mode().mode,
    }

    local cword = vim.fn.expand("<cword>")
    local popup_opt = popup_options()
    local prompt_win_id, _ = popup.create(cword, popup_opt)

    configure_window(prompt_win_id)

    -- Metadata used by the callback
    rename_popup._window_to_metadata[prompt_win_id] = callback_data
end

return rename_popup
