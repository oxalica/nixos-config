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

set timeoutlen=500

nnoremap <c-c> :%y+<cr>
vnoremap <c-c> :y+<cr>gv

nnoremap z <esc>:set wrap!<cr>
nnoremap <cr> <esc>:set hlsearch!<cr>

cnoremap w!! w !sudo tee % >/dev/null
