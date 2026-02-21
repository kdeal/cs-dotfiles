local rename_popup = {}

local function get_window_args()
    local col = 0
    local cursor = vim.api.nvim_win_get_cursor(0)
    if cursor[2] == 0 then
        col = 1
    end

    return {
        relative = "cursor",
        row = 2,
        col = col,
        width = 30,
        height = 1,
        border = "rounded",
        style = "minimal",
    }
end

local function create_popup(word, data)
    -- Create buffer with initial word
    local buf_id = vim.api.nvim_create_buf(false, true)
    vim.bo[buf_id].bufhidden = "wipe"
    vim.api.nvim_buf_set_lines(buf_id, 0, -1, true, { word })

    local win_id = vim.api.nvim_open_win(buf_id, true, get_window_args())
    vim.wo[win_id].winhl = "Normal:Normal,FloatBorder:Normal"

    vim.keymap.set({ "n", "i" }, "<CR>", function()
        require("rename_popup").on_submit(win_id, buf_id, data)
    end, { buffer = buf_id })
    vim.keymap.set({ "n" }, "<esc>", "<cmd>quit<CR>", { buffer = buf_id })
end

local function get_new_word(buffer_id)
    local buf_lines = vim.api.nvim_buf_get_lines(buffer_id, 0, -1, false)
    if #buf_lines > 1 then
        vim.notify("Popup buffer longer than 1 line, using last line", vim.log.levels.WARN)
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

function rename_popup.on_submit(win_id, buf_id, data)
    local new_word = get_new_word(buf_id)
    vim.api.nvim_win_close(win_id, true)

    if data then
        -- Switch back to initial window, so we can use builtin rename
        vim.api.nvim_set_current_win(data.win_id)
        vim.lsp.buf.rename(new_word)

        restore_mode(data.initial_mode)
    else
        vim.notify("No callback data, can't rename", vim.log.levels.WARN)
    end
end

function rename_popup.rename()
    local data = {
        win_id = vim.api.nvim_get_current_win(),
        initial_mode = vim.api.nvim_get_mode().mode,
    }

    local cword = vim.fn.expand("<cword>")
    create_popup(cword, data)
end

return rename_popup
