let g:markdown_folding=1
let g:vim_markdown_conceal=0
setlocal textwidth=80
setlocal makeprg=pandoc\ -o\ %:r.pdf\ %
