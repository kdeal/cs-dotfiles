if exists("did_load_filetypes")
    finish
endif

augroup filetypedetect
    autocmd!
    autocmd BufRead,BufNewFile *.flake8 setfiletype config
    autocmd BufRead,BufNewFile *Jenkinsfile set filetype=groovy
    autocmd BufRead,BufNewFile *OWNERS set filetype=yaml
    autocmd BufRead,BufNewFile *.tera set filetype=htmldjango
augroup END
