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

function! LinterStatus() abort
    " Update to lsp
    return ''
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
set statusline+=\ %f%h%q
set statusline+=%3*%{StatusModified()}%2*
set statusline+=\ %1*%{StatusReadonly()}%2*
set statusline+=%<
set statusline+=%=%{StatusFiletype()}
set statusline+=\ %{StatusFugitive()}
set statusline+=%4*%{LinterStatus()}%2*
set statusline+=%*\ %l:%c\ %P
