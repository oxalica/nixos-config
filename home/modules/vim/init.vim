set nocompatible
set encoding=utf-8 termencoding=utf-8
set fileencodings=ucs-bom,utf-8,gb18030,latin1

set tabstop=4 shiftwidth=4 softtabstop=4
set autoindent smarttab cindent
set expandtab 
set backspace=indent,eol,start

set cursorline
set number
set mouse=a

syntax on
colorscheme default

set ttimeoutlen=50

set <m-z>=z
nnoremap <m-z> <esc>:set wrap!<cr>
nnoremap <cr> <esc>:set hlsearch!<cr>

" Wordaround shortcut collision
inoremap <c-e> <c-w>

" Panes
nnoremap <c-w>v <esc>:vsplit<cr>
nnoremap <c-w>s <esc>:split<cr>
nnoremap <c-w>+ <c-w>+<c-w>+<c-w>+<c-w>+<c-w>+
nnoremap <c-w>- <c-w>-<c-w>-<c-w>-<c-w>-<c-w>-
nnoremap <c-w>< <c-w><<c-w><<c-w><<c-w><<c-w><
nnoremap <c-w>> <c-w>><c-w>><c-w>><c-w>><c-w>>

command -nargs=0 Wsudo :w !sudo tee % >/dev/null

