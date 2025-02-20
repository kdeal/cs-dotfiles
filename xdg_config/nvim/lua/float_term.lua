local floating_term = {}

local state = {
    buffer_id = nil,
    job_id = nil,
    window_id = nil,
}

local function get_window_args()
    -- -2 is for the border
    local width = math.ceil((vim.o.columns - 2) * 0.9)
    local height = math.ceil((vim.o.lines - 2) * 0.9)

    local col = math.ceil((vim.o.columns - width - 2) * 0.5)
    local row = math.ceil((vim.o.lines - height - 2) * 0.5)

    return {
        relative = "editor",
        row = row,
        col = col,
        width = width,
        height = height,
        border = "rounded",
    }
end

local function create_window()
    state.window_id = vim.api.nvim_open_win(state.buffer_id, true, get_window_args())
    vim.wo[state.window_id].winhl = "Normal:Normal,FloatBorder:Normal"
end

local function create_terminal()
    state.buffer_id = vim.api.nvim_create_buf(false, true)
    create_window()
    state.job_id = vim.fn.termopen(vim.o.shell)
end

local function close_term()
    vim.api.nvim_win_close(state.window_id, false)
    state.window_id = nil
end

function floating_term.toggle()
    if state.window_id and vim.api.nvim_win_is_valid(state.window_id) then
        close_term()
    else
        if state.buffer_id and vim.api.nvim_buf_is_valid(state.buffer_id) then
            create_window()
        else
            create_terminal()
        end
        vim.cmd("startinsert")
    end
end

return floating_term
