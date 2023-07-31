scriptencoding utf-8

function! StatusFugitive()
    if exists('*fugitive#head')
        let l:head = fugitive#head(7)
        if l:head ==# ''
            return ''
        else
            return '| ' . l:head . ' '
        endif
    endif
    return ''
endfunction

function! StatusFiletype()
    if &filetype !=# ''
        return &filetype
    endif
    return 'no filetype'
endfunction

function! StatusReadonly()
    if &readonly
        return 'RO'
    endif
    return ''
endfunction

function! StatusModified()
    if &modified
        return ' ●'
    endif
    return ''
endfunction

function! CurrentProject()
    return fnamemodify(getcwd(), ':t')
endfunction

lua << EOF
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
    local status = ''
    for severity, count in pairs(counts) do
        local section = string.format(' %d %s', count, severity_symbol[severity])
        status = status .. section
    end
    if status ~= '' then
        status = status .. ' '
    end
    return status
end
EOF

function! RecordStatus() abort
    let l:status_mode = luaeval('require("noice").api.statusline.mode.get()')
        if l:status_mode ==# 'v:null' || l:status_mode =~ '-- .\+ --'
            return ''
        else
            return l:status_mode
        endif
endfunction

" Read-only
highlight User1 ctermfg=1 ctermbg=10 guifg=#cc241d guibg=#32302f
" filename
highlight User2 ctermfg=8 ctermbg=10 guifg=#ebdbb2 guibg=#32302f
" Modified
highlight User3 ctermfg=166 ctermbg=10 cterm=bold guifg=#d65d0e guibg=#32302f gui=bold
" Linter
highlight User4 ctermfg=254 ctermbg=1 guifg=#1d2021 guibg=#fb4934

set statusline=\ %{CurrentProject()}
set statusline+=\ %2*
set statusline+=\ %{RecordStatus()}
set statusline+=%<
set statusline+=%=%{StatusFiletype()}
set statusline+=\ %{StatusFugitive()}
set statusline+=%4*%{v:lua.diagnostics_statusline()}%2*
set statusline+=%*\ %l:%c\ %P

set winbar=%2*
set winbar+=\ %f%h%q
set winbar+=%3*%{StatusModified()}%2*
set winbar+=\ %1*%{StatusReadonly()}%2*
