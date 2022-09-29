" Settings. {{{1

" Core.
set fileencodings=ucs-bom,utf-8,gb18030,latin1
set foldmethod=marker
set lazyredraw
set mouse=a
set scrolloff=5
set undofile

" No undo for tmp files
autocmd BufWritePre /tmp/*,/var/tmp/*,/dev/shm/* setlocal noundofile nobackup

" Input.
set shiftwidth=4
set softtabstop=-1 " Follows shiftwidth
set shiftround
set expandtab
set ttimeoutlen=1
set updatetime=1000

" Render.
set number
set cursorline
set hlsearch
set signcolumn=yes " Always show.
set list
set listchars=tab:-->,extends:>,precedes:<

" Highlight on yank.
autocmd TextYankPost * silent! lua vim.highlight.on_yank {higroup="IncSearch", timeout=200}

" TMUX takes precedence. Also enable OSC 52 clipboard via `-w`.
if !empty($TMUX)
  let g:clipboard = {
  \   'name': 'tmux',
  \   'copy': {
  \     '+': ['tmux', 'load-buffer', '-w', '-'],
  \     '*': ['tmux', 'load-buffer', '-w', '-'],
  \   },
  \   'paste': {
  \     '+': ['tmux', 'save-buffer', '-'],
  \     '*': ['tmux', 'save-buffer', '-'],
  \   },
  \ }
endif

" Status line.
" Reference: https://github.com/lilydjwg/dotvim/blob/07c4467153f2f44264fdb0e23c085b56cad519db/vimrc#L548
" <path/to/file [+][preview][RO][filetype][binary][encoding][BOM][dos][noeol]
"   === char code, line, column, byte position, percentage
set laststatus=2 " Always shown.
let &statusline=
  \ '%<%f %m%r%y' ..
  \ '%{&bin?"[binary]":""}' ..
  \ '%{!&bin&&&fenc!="utf-8"&&&fenc!=""?"[".&fenc."]":""}' ..
  \ '%{!&bin&&&bomb?"[BOM]":""}' ..
  \ '%{!&bin&&&ff!="unix"?"[".&ff."]":""}' ..
  \ '%{!&eol?"[noeol]":&bin?"[eol]":""}' ..
  \ ' %LL  %-8.{luaeval("require[[lsp-status]].status()")}' ..
  \ '%=' ..
  \ ' 0x%-4.B %-16.(%lL,%cC%V,%oB%) %P'

" Mappings. {{{1
let g:mapleader = '\'

" Clipboard
vmap <C-c> "+y

" Move lines.
nmap <C-j> :move+<CR>
nmap <C-k> :move-2<CR>
vmap <C-j> :move'>+<CR>gv
vmap <C-k> :move'<-2<CR>gv

" Mouse.
nmap <S-ScrollWheelDown> <ScrollWhellRight>
nmap <S-ScrollWheelUp>   <ScrollWhellLeft>
imap <S-ScrollWheelDown> <ScrollWhellRight>
imap <S-ScrollWheelUp>   <ScrollWhellLeft>

" Options
nmap <M-z> <Cmd>set wrap!\|set wrap?<CR>
nmap <M-CR> <Cmd>nohlsearch<CR>

" Commands. {{{1
command -nargs=0 Sudow w !sudo tee % >/dev/null
command -nargs=* W w <args>
