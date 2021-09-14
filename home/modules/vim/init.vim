" Core. {{{1
set nocompatible
set undofile
set lazyredraw
set mouse=a
set scrolloff=5
if has("unnamedplus") && !empty($DISPLAY)
  set clipboard^=unnamedplus
endif
if !has("nvim") && &term =~ '^tmux\|^alacritty'
  " Cursor shape
  let &t_SI = "\<Esc>[6 q"
  let &t_SR = "\<Esc>[4 q"
  let &t_EI = "\<Esc>[2 q"
endif

" Encoding. {{{1
set encoding=utf-8 termencoding=utf-8
set fileencodings=ucs-bom,utf-8,gb18030,latin1

" Input. {{{1
set tabstop=4 shiftwidth=4 softtabstop=4
set autoindent smarttab cindent
set expandtab
set backspace=indent,eol,start
set ttimeoutlen=50

" Render. {{{1
set number
set cursorline
set textwidth=120
set colorcolumn=120

if empty($COLORTERM)
  colorscheme default
else
  colorscheme lilypink
endif

" Show hidden spaces. {{{1
set list
set listchars=tab:-->,extends:>,precedes:<
highlight ExtraWhitespace ctermbg=red guibg=red
match ExtraWhitespace /\s\+$/
autocmd InsertEnter * match none
autocmd InsertLeave * match ExtraWhitespace /\s\+$/
" Use dark color for leading tabs.
highlight NormalLeadingTab ctermfg=237 guifg=#3a3a3a ctermbg=NONE guibg=NONE
let g:match_normal_leading_tab = matchadd('NormalLeadingTab', '^\t\+\S\@=')

" Strip extra spaces. {{{1
function! <SID>StripTrailingWhitespaces()
  if !&binary && &filetype != '' && &filetype != 'diff'
    let l:save = winsaveview()
    keeppatterns %s/\s\+$//e
    call winrestview(l:save)
  endif
endfun
autocmd BufWritePre <buffer> :call <SID>StripTrailingWhitespaces()

" XDGify for vim. {{{1
if empty($XDG_CONFIG_HOME)
  let $XDG_CONFIG_HOME = $HOME . "/.config"
endif
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

" Mapping. {{{1

let mapleader='\'
nnoremap Y y$

if !has('nvim')
  set <m-z>=z
endif
nnoremap <m-z> :set wrap!<cr>
inoremap <m-z> :set wrap!<cr>
inoremap <silent><expr> <m-z> execute("set wrap!")
nnoremap <leader>z :set wrap!<cr>

nnoremap <cr> :set hlsearch!<cr>

" Panes
nnoremap <c-w>v :vsplit<cr>
nnoremap <c-w>s :split<cr>
nnoremap <c-w>+ <c-w>+<c-w>+<c-w>+<c-w>+<c-w>+
nnoremap <c-w>- <c-w>-<c-w>-<c-w>-<c-w>-<c-w>-
nnoremap <c-w>< <c-w><<c-w><<c-w><<c-w><<c-w><
nnoremap <c-w>> <c-w>><c-w>><c-w>><c-w>><c-w>>

command -nargs=0 Sudow :w !sudo tee % >/dev/null

" Plugins. {{{1

" fcitx-vim {{{2
let g:fcitx5_remote = '@@fcitx5-remote@@'

" fzf-vim {{{2
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

" nerdcommenter {{{2
let g:NERDSpaceDelims = 1
let g:NERDDefaultAlign = 'left'
let g:NERDCommentEmptyLines = 1

" vim-highlightedyank {{{2
let g:highlightedyank_highlight_duration = 200

" vim-sandwich {{{2
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

" vim-smoothie {{{2
let g:smoothie_speed_linear_factor = 20

" coc-nvim {{{2
" https://github.com/neoclide/coc.nvim

let g:coc_start_at_startup = has('nvim')
" Home manager's `programs.neovim.coc` always writes to `$XDG_CONFIG_HOME/nvim/coc-settings.json`.
let g:coc_config_home = $XDG_CONFIG_HOME . "/nvim"
let g:coc_data_home = $XDG_DATA_HOME . "/coc"

inoremap <silent><expr> <c-@> coc#refresh()
inoremap <silent><expr> <cr> pumvisible() ? coc#_select_confirm() : "\<C-g>u\<CR>\<c-r>=coc#on_enter()\<CR>"

" Diagnostic
nmap <silent> [g <Plug>(coc-diagnostic-prev)
nmap <silent> ]g <Plug>(coc-diagnostic-next)

" Goto-like
nmap <silent> <leader>gd <Plug>(coc-definition)
nmap <silent> <leader>gy <Plug>(coc-type-definition)
nmap <silent> <leader>gi <Plug>(coc-implementation)
nmap <silent> <leader>gr <Plug>(coc-references)

" Renaming
nmap <leader>rn <Plug>(coc-rename)

" Formatting selected code
xmap <leader>f  <Plug>(coc-format-selected)
nmap <leader>f  <Plug>(coc-format-selected)

" Actions
xmap <leader>a <Plug>(coc-codeaction-selected)
" for file
nmap <leader>af <Plug>(coc-codeaction)
" for line
nmap <leader>al <Plug>(coc-codeaction-line)
" for cursor empty range
nmap <leader>a<space> <Plug>(coc-codeaction-cursor)
imap <c-a> <Plug>(coc-codeaction-cursor)

" Map function and class text objects
" NOTE: Requires 'textDocument.documentSymbol' support from the language server.
xmap if <Plug>(coc-funcobj-i)
omap if <Plug>(coc-funcobj-i)
xmap af <Plug>(coc-funcobj-a)
omap af <Plug>(coc-funcobj-a)
xmap ic <Plug>(coc-classobj-i)
omap ic <Plug>(coc-classobj-i)
xmap ac <Plug>(coc-classobj-a)
omap ac <Plug>(coc-classobj-a)

" Add `:Format` command to format current buffer.
command! -nargs=0 Format :call CocAction('format')

" coc-rust-analyzer {{{2
" let g:rustfmt_autosave = 1

" }}}1
" vim: sw=2 et :
