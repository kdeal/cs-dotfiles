_G.nnoremap = function(key, command, opts)
    opts = opts or {}
    opts.noremap = true
    vim.api.nvim_set_keymap("n", key, command, opts)
end

_G.vnoremap = function(key, command, opts)
    opts = opts or {}
    opts.noremap = true
    vim.api.nvim_set_keymap("v", key, command, opts)
end

_G.snoremap = function(key, command, opts)
    opts = opts or {}
    opts.noremap = true
    vim.api.nvim_set_keymap("s", key, command, opts)
end

_G.inoremap = function(key, command, opts)
    opts = opts or {}
    opts.noremap = true
    vim.api.nvim_set_keymap("i", key, command, opts)
end

_G.tnoremap = function(key, command, opts)
    opts = opts or {}
    opts.noremap = true
    vim.api.nvim_set_keymap("t", key, command, opts)
end

_G.noremap = function(key, command, opts)
    opts = opts or {}
    opts.noremap = true
    vim.api.nvim_set_keymap("n", key, command, opts)
    vim.api.nvim_set_keymap("v", key, command, opts)
    vim.api.nvim_set_keymap("s", key, command, opts)
    vim.api.nvim_set_keymap("o", key, command, opts)
end

vim.opt.termguicolors = true

-- Make backspacing work like I expect it to
vim.opt.backspace = { "indent", "eol", "start" }

-- Status line settings (3 = global status bar)
vim.opt.laststatus = 3

vim.g.mapleader = " "

-- Show line before or after
vim.opt.scrolloff = 5

vim.opt.colorcolumn = { 80, 120 }

-- Color scheme settings
vim.cmd("syntax on")
vim.opt.synmaxcol = 200

-- Auto resize the windows on resize
vim.cmd([[
    augroup vimrc
        autocmd!
        autocmd VimResized * wincmd =
    augroup END
]])

-- Don't use mouse most of the time, annoying for copying
vim.opt.mouse = "ar"

vim.opt.foldmethod = "indent"
vim.opt.foldlevel = 99

-- Autoload files from disk
vim.opt.autoread = true

-- Show special things
vim.opt.list = true
vim.opt.listchars = { tab = "··»", trail = "·" }
vim.opt.showbreak = "»»"

-- Indenting
vim.opt.cindent = true
vim.opt.tabstop = 4
vim.opt.shiftwidth = 0
vim.opt.expandtab = true
vim.opt.smarttab = true
vim.opt.shiftround = true
vim.opt.autoindent = true
vim.opt.wrap = true
vim.opt.startofline = false
vim.cmd("filetype plugin indent on")

-- Can hide motified buffers
vim.opt.hidden = true

-- Increment letters
vim.opt.nrformats:append({ "alpha" })

-- Don't prompt on multiple vims editing same file without changes
-- c = don't show completion messages
vim.opt.shortmess:append("IAc")

-- Tab complete more bash like
vim.opt.wildmode = "longest:full"
vim.opt.wildmenu = true
-- Use a popup menu for completions, only insert once completions is selected
vim.opt.completeopt = { "menuone", "noinsert", "noselect" }

-- Searching
vim.opt.incsearch = true -- Search as typing
vim.opt.ignorecase = true
vim.opt.infercase = true -- Better casing during completions
vim.opt.smartcase = true
vim.opt.hlsearch = true
vim.opt.gdefault = true -- Automatically use /g when doing a search replace

vim.opt.inccommand = "split"

-- Set command window to 2 lines, avoids press enter to continue
vim.opt.cmdheight = 2
vim.opt.showcmd = true

-- Don't show the tabline
vim.opt.showtabline = 0

-- Encoding
vim.opt.fileencoding = "utf-8"

-- Split stuff
vim.opt.splitbelow = true
vim.opt.splitright = true

-- Remember more things
vim.opt.history = 1000
vim.opt.undolevels = 1000

-- Persistant undo
vim.opt.undofile = true

vim.opt.spelllang = { "en_us", "it" }
vim.opt.spell = true

-- Use ripgrep for greping
vim.opt.grepprg = "rg --vimgrep"

-- Movement mappings
nnoremap("j", "gj")
nnoremap("k", "gk")
nnoremap("gj", "j")
nnoremap("gk", "k")

-- Random maps
nnoremap("<leader>nh", "<cmd>nohlsearch<CR>", { silent = true })
nnoremap("<leader>ot", "<cmd>lua require('float_term').toggle()<CR>", { silent = true })
nnoremap("<leader>oT", "<cmd>terminal<CR>", { silent = true })
nnoremap("<leader>ol", "<cmd>lopen<CR>", { silent = true })
nnoremap("<leader>oc", "<cmd>copen<CR>", { silent = true })

nnoremap("<leader>ss", "<cmd>syntax sync fromstart<CR>", { silent = true })

-- Basic editing mappings
noremap("<leader>w", "<cmd>w<CR>", { silent = true })
noremap("<leader>q", "<cmd>q<CR>", { silent = true })
noremap("<leader>Q", "<cmd>qall<CR>", { silent = true })
noremap("<leader>cq", "<cmd>cq<CR>", { silent = true })
noremap("<leader>e", ":e ")
noremap("<leader>Eh", ":e %%")

vim.cmd("cabbr <expr> %% expand('%:p:h')")
noremap("<leader>Ev", "<cmd>e $MYVIMRC<CR>", { silent = true })

-- Better visual mode pasting
vnoremap("P", "p")
vnoremap("p", "pgvy")

-- Tabs mappings
noremap("<leader>tc", "<cmd>tabnew<CR>", { silent = true })

-- buffer mappings
noremap("<leader>bd", "<cmd>lua MiniBufremove.delete(0, false)<CR>", { silent = true })

-- window mappings
noremap("<leader>j", "<C-W><C-J>")
noremap("<leader>k", "<C-W><C-K>")
noremap("<leader>h", "<C-W><C-H>")
noremap("<leader>l", "<C-W><C-L>")
noremap("<leader>sp", "<cmd>sp<CR>", { silent = true })
noremap("<leader>vs", "<cmd>vs<CR>", { silent = true })
noremap("<leader>bh", "<cmd>hide<CR>", { silent = true })

-- Terminal mappings
tnoremap("<c-->", "<c-\\><c-n>")
vim.cmd([[
    augroup vimrcterminal
        autocmd!
        autocmd TermOpen * setlocal nonumber
    augroup END
]])

-- TODO: Port to lua
vim.cmd([[
    function SyntaxItem()
        echo synIDattr(synID(line('.'), col('.'), 1), 'name')
    endfunction
]])

noremap("<leader>os", "<cmd>call SyntaxItem()<cr>", { silent = true })

-- Color of text after yanking
vim.cmd([[
    augroup LuaHighlight
        autocmd!
        autocmd TextYankPost * silent! lua vim.highlight.on_yank({timeout=250})
    augroup END
]])

-- Diagnostic config
nnoremap("<leader>od", "<cmd>lua vim.diagnostic.setloclist({ open = true })<cr>", { silent = true })
nnoremap("<leader>d", '<cmd>lua vim.diagnostic.open_float(nil, { scope = "cursor" })<cr>', { silent = true })

vim.diagnostic.config({ virtual_text = false })

vim.fn.sign_define("DiagnosticSignError", { text = "✘", texthl = "DiagnosticSignError", linehl = "", numhl = "" })
vim.fn.sign_define("DiagnosticSignWarn", { text = "⚑", texthl = "DiagnosticSignWarn", linehl = "", numhl = "" })
vim.fn.sign_define("DiagnosticSignInfo", { text = "ℹ", texthl = "DiagnosticSignInfo", linehl = "", numhl = "" })
vim.fn.sign_define("DiagnosticSignHint", { text = "🞇", texthl = "DiagnosticSignHint", linehl = "", numhl = "" })

vim.filetype.add({
    extension = {
        Jenkinsfile = "groovy",
    },
    filename = {
        ["OWNERS"] = "yaml",
    },
})

local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
local utils = require("misc")

if not vim.loop.fs_stat(lazypath) then
    local lock_filepath = vim.fn.stdpath("config") .. "/lazy-lock.json"
    local lazy_lock_data = vim.json.decode(utils.read_file(lock_filepath))["lazy.nvim"]
    vim.fn.system({
        "git",
        "clone",
        "--filter=blob:none",
        "https://github.com/folke/lazy.nvim.git",
        string.format("--branch=%s", lazy_lock_data.branch), -- latest stable release
        lazypath,
    })
    vim.fn.system({
        "git",
        "-C",
        lazypath,
        "checkout",
        lazy_lock_data.commit,
    })
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup("plugins")
