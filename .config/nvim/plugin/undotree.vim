scriptencoding utf-8

nnoremap <silent> <leader>ou :UndotreeToggle<CR>

" Move cursor into window when opening
let g:undotree_SetFocusWhenToggle = 1
" Don't show diff by default
let g:undotree_DiffAutoOpen = 0

" Change lines a little bit
let g:undotree_TreeNodeShape = '◆'
let g:undotree_TreeReturnShape = '╲'
let g:undotree_TreeVertShape = '│'
let g:undotree_TreeSplitShape = '╱'
