" Core. {{{1
" Vim is always in nocompatible mode when this file is loaded.
set undofile
set lazyredraw
set mouse=a
set scrolloff=5
set updatetime=1000
set foldmethod=marker

" No undo for tmp files
autocmd BufWritePre /tmp/*,/var/tmp/*,/dev/shm/* setlocal noundofile nobackup

" Encoding. {{{1
set encoding=utf-8 termencoding=utf-8
set fileencodings=ucs-bom,utf-8,gb18030,latin1

" Input. {{{1
set tabstop=8 shiftwidth=4 softtabstop=4
set autoindent smarttab expandtab
" Always use lexical indentation for content inside parenthesis (function call, if conditions, etc).
set cinoptions=(s

set backspace=indent,eol,start
set ttimeoutlen=1

" Render. {{{1
set number
set cursorline
set signcolumn=yes
set textwidth=99
set list
set listchars=tab:-->,extends:>,precedes:<

" Always show status line
set laststatus=2
" Reference: https://github.com/lilydjwg/dotvim/blob/07c4467153f2f44264fdb0e23c085b56cad519db/vimrc#L548
" <path/to/file [+][preview][RO][filetype][binary][encoding][BOM][dos][noeol]
"   === char code, line, column, byte position, percentage
set statusline=%<%f\ %m%r%y
  \%{&bin?'[binary]':''}
  \%{!&bin&&&fenc!='utf-8'&&&fenc!=''?'['.&fenc.']':''}
  \%{!&bin&&&bomb?'[BOM]':''}
  \%{!&bin&&&ff!='unix'?'['.&ff.']':''}
  \%{!&eol?'[noeol]':&bin?'[eol]':''}
  \\ %LL\ \ %-8.{has('nvim')?coc#status():''}
  \%=\ 0x%-4.B\ %-16.(%lL,%cC%V,%oB%)\ %P

" XDG & Vim fixup. {{{1

if empty($XDG_CONFIG_HOME)
  let $XDG_CONFIG_HOME = $HOME . "/.config"
endif
if empty($XDG_DATA_HOME)
  let $XDG_DATA_HOME = $HOME . "/.local/share"
endif

if !has('nvim')
  " XDGify.
  call mkdir($XDG_DATA_HOME . '/vim/undo', 'p')
  call mkdir($XDG_DATA_HOME . '/vim/swap', 'p')
  call mkdir($XDG_DATA_HOME . '/vim/backup', 'p')
  set undodir=$XDG_DATA_HOME/vim/undo
  set directory=.,$XDG_DATA_HOME/vim/swap
  set backupdir=.,$XDG_DATA_HOME/vim/backup
  set viminfofile=$XDG_DATA_HOME/vim/viminfo

  " Cursor shape.
  if &term =~ '^tmux\|^alacritty'
    let &t_SI = "\e[6 q"
    let &t_SR = "\e[4 q"
    let &t_EI = "\e[2 q"
  endif

  " <M-> escapes.
  for c in split("ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz", '\zs')
    exec "set <m-" . c . ">=\e" . c
  endfor
endif

" Mapping. {{{1

let mapleader='\'
nnoremap Y y$

map <m-z> <cmd>set wrap!<cr>
imap <expr> <m-z> execute('set wrap!')
nnoremap <cr> <cmd>set hlsearch! \| set hlsearch?<cr>

" Panes
nnoremap <c-w>v :vsplit<cr>
nnoremap <c-w>s :split<cr>
nnoremap <c-w>+ <c-w>+<c-w>+<c-w>+<c-w>+<c-w>+
nnoremap <c-w>- <c-w>-<c-w>-<c-w>-<c-w>-<c-w>-
nnoremap <c-w>< <c-w><<c-w><<c-w><<c-w><<c-w><
nnoremap <c-w>> <c-w>><c-w>><c-w>><c-w>><c-w>>

command -nargs=0 Sudow w !sudo tee % >/dev/null
command -nargs=* W w <args>

function! Syn()
  if !exists("*synstack")
    return
  endif
  echo map(synstack(line('.'), col('.')), 'synIDattr(v:val, "name")')
endfunc
command -nargs=0 Syn call Syn()

" Plugins. {{{1

" auto-pairs
let g:AutoPairsCenterLine = 0
let g:AutoPairsMultilineClose = 0

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
" Fullscreen by default for :Rg
command! -nargs=* Rg call fzf#vim#grep("rg --column --line-number --no-heading --color=always --smart-case -- ".shellescape(<q-args>), 1, fzf#vim#with_preview(), 1)

" nerdcommenter {{{2
let g:NERDSpaceDelims = 1
let g:NERDDefaultAlign = 'left'
let g:NERDCommentEmptyLines = 1

" sleuth {{{2
" Don't search for neighbor files. Just detect the file itself.
let g:sleuth_neighbor_limit = 0

" vim-better-whitespace {{{2
let g:show_spaces_that_precede_tabs = 1

" vim-cursorword {{{2
let g:cursorword_delay = 0 " Immediate refresh

" vim-highlightedyank {{{2
let g:highlightedyank_highlight_duration = 200

" vim-sandwich {{{2
" Use vim-surround keymap.
runtime PACK macros/sandwich/keymap/surround.vim
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
if has('nvim')
  let g:coc_start_at_startup = has('nvim')
  " Home manager's `programs.neovim.coc` always writes to `$XDG_CONFIG_HOME/nvim/coc-settings.json`.
  let g:coc_config_home = $XDG_CONFIG_HOME . "/nvim"
  let g:coc_data_home = $XDG_DATA_HOME . "/coc"

  inoremap <silent><expr> <c-space> coc#refresh()
  inoremap <silent><expr> <tab> pumvisible() ? coc#_select_confirm() : "\<tab>"

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
  nmap <leader>ag <Plug>(coc-codeaction)
  " for line
  nmap <leader>aa <Plug>(coc-codeaction-line)
  " for cursor empty range
  nmap <leader>a<space> <Plug>(coc-codeaction-cursor)

  " Add `:Format` command to format current buffer.
  command! -nargs=0 Format :call CocAction('format')
end

" Color schemes. {{{1

" Manually bring plugin into scope. Required for vim.
packadd nightfox-nvim
lua <<EOF
  require("nightfox").setup {
    fox = "nightfox",
    colors = {
      hint = "blue";
    };
    hlgroups = {
      SpecialKey = { fg = "${magenta_dm}" },

      -- better-whitespace.vim
      ExtraWhitespace = { bg = "${error}" },

      -- vim-highlightedyank
      HighlightedyankRegion = { bg = "${bg_search}" },

      -- coc.nvim
      CocErrorSign = { fg = "${error}" },
      CocWarningSign = { fg = "${warning}" },
      CocHintSign = { fg = "${hint}" },
      CocErrorHighlight = { bg = "${bg_alt}", style = "NONE" },
      CocWarningHighlight = { bg = "${bg_alt}", style = "NONE" },
      CocHintHighlight = { bg = "${bg_alt}", style = "NONE" },
    },
  }
EOF

if !empty($COLORTERM)
  if !has('nvim')
    let &t_8f = "\<Esc>[38;2;%lu;%lu;%lum"
    let &t_8b = "\<Esc>[48;2;%lu;%lu;%lum"
  endif
  colorscheme nightfox
endif

" }}}1
" vim: sw=2 et :
