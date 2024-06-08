local floating_term = {}

local state = {
    buffer_id = nil,
    job_id = nil,
    window_id = nil,
}

local function get_window_args()
    local width = math.ceil(vim.o.columns * 0.9)
    local height = math.ceil(vim.o.lines * 0.9)

    local col = math.ceil((vim.o.columns - width) * 0.5)
    local row = math.ceil((vim.o.lines - height) * 0.5)

    return {
        relative = "editor",
        row = row,
        col = col,
        width = width,
        height = height,
    }
end

local function create_terminal()
    state.buffer_id = vim.api.nvim_create_buf(false, true)
    state.window_id = vim.api.nvim_open_win(state.buffer_id, true, get_window_args())
    state.job_id = vim.fn.termopen(vim.o.shell)
end

local function reopen_term()
    state.window_id = vim.api.nvim_open_win(state.buffer_id, true, get_window_args())
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
            reopen_term()
        else
            create_terminal()
        end
        vim.cmd("startinsert")
    end
end

return floating_term
