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
set scrolloff=5

set ttimeoutlen=50

" Line limit.
set textwidth=120
set colorcolumn=120

syntax on
if empty(matchstr($TERM, '256color'))
  colorscheme default
else
  colorscheme lilypink
endif

" Show hidden spaces.
set list
set listchars=tab:-->,extends:>,precedes:<
highlight ExtraWhitespace ctermbg=red guibg=red
match ExtraWhitespace /\s\+$/
autocmd InsertEnter * match none
autocmd InsertLeave * match ExtraWhitespace /\s\+$/
" Use dark color for leading tabs.
highlight NormalLeadingTab ctermfg=237 guifg=#3a3a3a ctermbg=NONE guibg=NONE
let g:match_normal_leading_tab = matchadd('NormalLeadingTab', '^\t\+\S\@=')

" Strip extra spaces.
function! <SID>StripTrailingWhitespaces()
  if !&binary && &filetype != '' && &filetype != 'diff'
    let l:save = winsaveview()
    keeppatterns %s/\s\+$//e
    call winrestview(l:save)
  endif
endfun
autocmd BufWritePre <buffer> :call <SID>StripTrailingWhitespaces()

" Mappings
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

command -nargs=0 Sudow :w !sudo tee % >/dev/null

