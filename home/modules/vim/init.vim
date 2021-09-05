" ================ Setting ================
" Core.
set nocompatible
set undofile
set lazyredraw
set mouse=a
set scrolloff=5

" Encoding.
set encoding=utf-8 termencoding=utf-8
set fileencodings=ucs-bom,utf-8,gb18030,latin1

" Input.
set tabstop=4 shiftwidth=4 softtabstop=4
set autoindent smarttab cindent
set expandtab
set backspace=indent,eol,start
set ttimeoutlen=50

" Render.
set number
set cursorline
set textwidth=120
set colorcolumn=120

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

" XDGify for vim
if empty($XDG_DATA_HOME)
  let $XDG_DATA_HOME = $HOME . "/.local/share"
endif
if !has('nvim')
  call mkdir($XDG_DATA_HOME . '/vim/undo', 'p')
  call mkdir($XDG_DATA_HOME . '/vim/swap', 'p')
  call mkdir($XDG_DATA_HOME . '/vim/backup', 'p')
  set undodir=$XDG_DATA_HOME/vim/undo
  set directory=.,$XDG_DATA_HOME/vim/swap
  set backupdir=.,$XDG_DATA_HOME/vim/backup
  set viminfofile=$XDG_DATA_HOME/vim/viminfo
endif

" ================ Mapping ================

let mapleader='\'

nnoremap Y y$

if !has('nvim')
  set <m-z>=z
endif
nnoremap <m-z> <esc>:set wrap!<cr>
nnoremap <leader>z <esc>:set wrap!<cr>
nnoremap <cr> <esc>:set hlsearch!<cr>

" Panes
nnoremap <c-w>v <esc>:vsplit<cr>
nnoremap <c-w>s <esc>:split<cr>
nnoremap <c-w>+ <c-w>+<c-w>+<c-w>+<c-w>+<c-w>+
nnoremap <c-w>- <c-w>-<c-w>-<c-w>-<c-w>-<c-w>-
nnoremap <c-w>< <c-w><<c-w><<c-w><<c-w><<c-w><
nnoremap <c-w>> <c-w>><c-w>><c-w>><c-w>><c-w>>

command -nargs=0 Sudow :w !sudo tee % >/dev/null

" ================ Plugins ================

" fcitx-vim
let g:fcitx5_remote = '@@fcitx5-remote@@'

" fzf-vim
let g:fzf_history_dir = $XDG_DATA_HOME . '/fzf.vim/history'
let g:fzf_action = {
    \ 'ctrl-t': 'tab split',
    \ 'ctrl-s': 'split',
    \ 'ctrl-v': 'vsplit',
    \ }
function FzfAt(path)
  let full_path = fnamemodify(a:path, ':p')
  let name = 'fd-' . substitute(full_path, '/', '%', 'g')
  let simple_path = fnamemodify(full_path, ':~:.')
  if empty(simple_path)
    let simple_path = getcwd() . '/'
  endif
  if len(simple_path) > 32
    let simple_path = pathshorten(simple_path[:-2]) . '/'
  endif
  let opts = { 'dir': full_path, 'options': ['--prompt', simple_path] }
  " Run in fullscreen mode.
  call fzf#run(fzf#wrap(name, opts, 1))
endfunction
nnoremap <silent> <leader>ff :call FzfAt('.')<cr>
nnoremap <silent> <leader>f. :call FzfAt(expand('%:p:h'))<cr>

" nerdcommenter
let g:NERDSpaceDelims = 1
let g:NERDDefaultAlign = 'left'
let g:NERDCommentEmptyLines = 1

" vim-highlightedyank
let g:highlightedyank_highlight_duration = 200

" vim-sandwich
runtime START **/sandwich/keymap/surround.vim
" Use behavior of vim-surround for left parenthesis input. https://github.com/machakann/vim-sandwich/issues/44
let g:sandwich#recipes += [
  \   {'buns': ['{ ', ' }'], 'nesting': 1, 'match_syntax': 1, 'kind': ['add', 'replace'], 'action': ['add'], 'input': ['{']},
  \   {'buns': ['[ ', ' ]'], 'nesting': 1, 'match_syntax': 1, 'kind': ['add', 'replace'], 'action': ['add'], 'input': ['[']},
  \   {'buns': ['( ', ' )'], 'nesting': 1, 'match_syntax': 1, 'kind': ['add', 'replace'], 'action': ['add'], 'input': ['(']},
  \   {'buns': ['{\s*', '\s*}'],   'nesting': 1, 'regex': 1, 'match_syntax': 1, 'kind': ['delete', 'replace', 'textobj'], 'action': ['delete'], 'input': ['{']},
  \   {'buns': ['\[\s*', '\s*\]'], 'nesting': 1, 'regex': 1, 'match_syntax': 1, 'kind': ['delete', 'replace', 'textobj'], 'action': ['delete'], 'input': ['[']},
  \   {'buns': ['(\s*', '\s*)'],   'nesting': 1, 'regex': 1, 'match_syntax': 1, 'kind': ['delete', 'replace', 'textobj'], 'action': ['delete'], 'input': ['(']},
  \ ]

" vim-smoothie
let g:smoothie_speed_linear_factor = 20

" coc-nvim
let g:coc_start_at_startup=has('nvim')
inoremap <silent><expr> <c-@> coc#refresh()
inoremap <silent><expr> <cr> pumvisible() ? coc#_select_confirm() : "\<C-g>u\<CR>\<c-r>=coc#on_enter()\<CR>"
nnoremap <leader>a <Plug>(coc-codeaction-line)

" coc-rust-analyzer
" let g:rustfmt_autosave = 1

" vim: sw=2 et :
