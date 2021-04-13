set nocompatible
set encoding=utf-8 termencoding=utf-8
set fileencodings=ucs-bom,utf-8,gb18030,latin1

set tabstop=4 shiftwidth=4 softtabstop=4
set autoindent smarttab cindent
set expandtab 
set backspace=indent,eol,start

set cursorline
set number
set mouse=

syntax on
colorscheme default

set ttimeoutlen=50

set <m-z>=z
nnoremap <m-z> <esc>:set wrap!<cr>
nnoremap <cr> <esc>:set hlsearch!<cr>

command -nargs=0 Wsudo :w !sudo tee % >/dev/null

