" Kyle Deal's Vimrc

" Set no compatible
set nocompatible
set backspace=indent,eol,start

" Status line settings
set laststatus=2
set statusline=%t%h%m\ 
set statusline+=%#warningmsg#
set statusline+=%*
set statusline+=%r%=%l/%L,%c\ %P

" Set map leader
let mapleader = " "

" Break line chacter
set showbreak=»»

" Movement keys
nnoremap j gj
nnoremap k gk

" Show line before or after
set scrolloff=5
set guioptions-=rL

set gdefault

" Color scheme settings
syntax on
set background=dark

" Change backup and swap location
set backupdir=~/.vim/backup
set directory=~/.vim/backup

set foldmethod=indent
set foldlevelstart=99

" Set the Tab Label
set guitablabel=\[%N\]%M\ %t

" Autoload files from disk
set autoread

" Show spaces and tabs
set encoding=utf-8
set list
set listchars=trail:·

" Indenting
set cindent
set tabstop=4
set shiftwidth=4
set expandtab
set smarttab
set ai " Auto indent
set si " Smart indent
set wrap " Wrap lines
set nostartofline
filetype plugin indent on

" Switching buffers mappings
set hidden " Can hide motified buffers

" Tab complete more bash like
set wildmode=longest:full
set wildmenu
set completeopt=menu,longest

" Searching
set incsearch " Search as typing
set ignorecase
set smartcase

" Enable use of the mouse for all modes
set mouse=a

" Set command window to 2 lines, avoids press enter to continue
set cmdheight=2
set showcmd

" Encoding
set encoding=utf-8
set fileencoding=utf-8

" Random maps
noremap <leader>w :w<CR>
noremap <leader>q :q<CR>
noremap <leader>x :x<CR>
noremap <leader>ev :e ~/.vimrc<CR>
noremap <leader>r :source ~/.vimrc<CR>
noremap ]b :bnext<CR>
noremap [b :bprevious<CR>
noremap <leader>j <C-W><C-J>
noremap <leader>k <C-W><C-K>
noremap <leader>h <C-W><C-H>
noremap <leader>l <C-W><C-L>
noremap <leader>sp :sp<CR>
noremap <leader>vs :vs<CR>
noremap <leader>bd :bn <bar> bd #<CR>
noremap <UP> :resize +5<CR>
noremap <DOWN> :resize -5<CR>
noremap <RIGHT> :vertical resize +5<CR>
noremap <LEFT> :vertical resize -5<CR>

" Remember more things
set history=1000
set undolevels=1000

" Timeout setting
set timeoutlen=1000
set ttimeoutlen=0

" Persistant undo
set undofile
set undodir=~/.vim/undo

set spelllang=en_us
set spell

" clipboard
set clipboard=unnamed
