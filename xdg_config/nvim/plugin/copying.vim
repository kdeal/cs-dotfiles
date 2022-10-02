" Add command to copy to clipboard
nmap <silent> <leader>y :set opfunc=CopyText<CR>g@
vmap <silent> <leader>y :<C-U>call CopyText(visualmode(), 1)<CR>

function! CopyText(type, ...)
    let l:sel_save = &selection
    let &selection = 'inclusive'
    let l:reg_save = @@

    if a:0  " Invoked from Visual mode, use gv command.
        silent exe 'normal! gvy'
    elseif a:type ==? 'line'
        silent exe "normal! '[V']y"
    else
        silent exe 'normal! `[v`]y'
    endif

    let l:osc52_str = system('yank', @@)
    call chansend(v:stderr, l:osc52_str)

    let &selection = l:sel_save
    let @@ = l:reg_save
endfunction
