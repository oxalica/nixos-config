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
set updatetime=500 " coc.nvim relies on relatively fast CursorHold.

" Render.
set number
set relativenumber
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
"   === status
"   === char code, line, column, byte position, percentage, total lines
set laststatus=2 " Always shown.
let &statusline=
  \ '%<%f %m%r%y' ..
  \ '%{&bin?"[binary]":""}' ..
  \ '%{!&bin&&&fenc!="utf-8"&&&fenc!=""?"[".&fenc."]":""}' ..
  \ '%{!&bin&&&bomb?"[BOM]":""}' ..
  \ '%{!&bin&&&ff!="unix"?"[".&ff."]":""}' ..
  \ '%{!&eol?"[noeol]":&bin?"[eol]":""}' ..
  \ '  %-8.{coc#status().." "..get(b:,"coc_current_function","")}' ..
  \ '%=' ..
  \ ' 0x%-4.B %-16.(%l,%c%V %oB%) %P %LL'

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
nmap <M-n> <Cmd>set relativenumber!\|set relativenumber?<CR>
nmap <M-z> <Cmd>set wrap!\|set wrap?<CR>
nmap <M-CR> <Cmd>nohlsearch<CR>

" Commands. {{{1
command! -nargs=0 Sudow w !sudo tee % >/dev/null
command! -nargs=* W w <args>

" Plugins. {{{1

" plugin: vim-repeat

" plugin: plenary-nvim

" plugin: vim-nix

" plugin: fcitx-vim

" plugin: fzf-vim {{{
let g:fzf_history_dir = stdpath('cache') . '/fzf_history'

function! s:build_quickfix_list(lines)
  call setqflist(map(copy(a:lines), '{ "filename": v:val }'))
  copen
  cc
endfunction
let g:fzf_action = {
    \ 'ctrl-q': function('s:build_quickfix_list'),
    \ 'ctrl-t': 'tab split',
    \ 'ctrl-s': 'split',
    \ 'ctrl-v': 'vsplit',
    \ }

function! FZFRg(pat, args, fullscreen)
  let args = "--column --line-number --no-heading --color=always " . a:args
  call fzf#vim#grep("rg " . args . " -- " . shellescape(a:pat), 1, fzf#vim#with_preview(), a:fullscreen)
endfunction
command -nargs=1 -bang RgF call FZFRg(<q-args>, "--fixed-strings", <bang>0)
nmap <Leader>ff <Cmd>call fzf#vim#files("", fzf#vim#with_preview(), 0)<CR>
nmap <Leader>f. <Cmd>call fzf#vim#files(expand('%:h'), fzf#vim#with_preview(), 0)<CR>
nmap <Leader>fp <Cmd>call fzf#vim#files(expand('%:h:h'), fzf#vim#with_preview(), 0)<CR>
nmap <Leader>fw <Cmd>call FZFRg(expand('<cword>'), '--fixed-strings --word-regexp', 0)<CR>
nmap <Leader>fb <Cmd>Buffers<CR>
nmap <Leader>fh <Cmd>Helptags<CR>
nmap <Leader>fr :Rg<Space>
"}}}

" plugin: gitgutter

" plugin: leap-nvim
lua require('leap').add_default_mappings()

" plugin: markdown-preview-nvim

" plugin: nerdcommenter {{{
let g:NERDCreateDefaultMappings = 1
let g:NERDSpaceDelims = 1
let g:NERDDefaultAlign = 'left'
let g:NERDCommentEmptyLines = 1
let g:NERDTrimTrailingWhitespace = 1
"}}}

" plugin: vim-better-whitespace {{{
let g:show_spaces_that_precede_tabs = 1
"}}}

" plugin: vim-fugitive {{{
" plugin: fugitive-gitlab-vim
" plugin: vim-rhubarb

nmap <F2> <Cmd>tab Git<CR>
command -nargs=* GL tab Git log --max-count=500 <args>
"}}}

" plugin: vim-sandwich {{{
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
"}}}

" plugin: crates-nvim {{{
" Should be setup early, or it cannot trigger autocmd inside autocmd.
lua require('crates').setup()
"}}}

" plugin: nvim-treesitter {{{
" plugin: playground
lua <<EOF
  require("nvim-treesitter.configs").setup {
    highlight = {
      enable = true,
      disable = function(lang, bufnr)
        return vim.api.nvim_buf_line_count(bufnr) > 10000
      end,
    },
    playground = {
      enable = true,
    },
  }
EOF
"}}}

" plugin: nightfox-nvim {{{
lua <<EOF
  require("nightfox").setup {
    groups = {
      all = {
        -- vim-better-whitespace
        ExtraWhitespace = { bg = "palette.red.dim" },

        SpecialComment = { fg = "palette.fg1" },
        SpecialString = { fg = "palette.green.bright" },

        CocHighlightWrite = { bg = "palette.bg3", style = "underline" },

        ["@string.special.nix"] = { link = "PreProc" },
        ["@field.rust"] = { link = "@field" },
        ["@field.yaml"] = { link = "@field" },
      },
    },
  }

  if vim.env.TMUX ~= nil or vim.env.COLORTERM ~= nil then
    vim.cmd('colorscheme nightfox')
  end
EOF
"}}}

" coc.nvim {{{1
" The plugins will be automatically enabled via h-m options.
" Mostly follows https://github.com/neoclide/coc.nvim#example-vim-configuration

" Completion.
inoremap <silent><expr> <Tab> coc#pum#visible() ? coc#_select_confirm() : "\<Tab>"
inoremap <silent><expr> <C-Space> coc#refresh()

" Motion.
nmap <silent> gd <Plug>(coc-definition)
nmap <silent> gy <Plug>(coc-type-definition)
nmap <silent> gi <Plug>(coc-implementation)
nmap <silent> gr <Plug>(coc-references)

nmap <silent> [d <Plug>(coc-diagnostic-prev)
nmap <silent> ]d <Plug>(coc-diagnostic-next)

nmap <silent> <C-s> <Plug>(coc-range-select)
xmap <silent> <C-s> <Plug>(coc-range-select)

xmap if <Plug>(coc-funcobj-i)
omap if <Plug>(coc-funcobj-i)
xmap af <Plug>(coc-funcobj-a)
omap af <Plug>(coc-funcobj-a)
xmap ic <Plug>(coc-classobj-i)
omap ic <Plug>(coc-classobj-i)
xmap ac <Plug>(coc-classobj-a)
omap ac <Plug>(coc-classobj-a)

" Scrolling.
nnoremap <silent><nowait><expr> <C-f> coc#float#has_scroll() ? coc#float#scroll(1) : "\<C-f>"
nnoremap <silent><nowait><expr> <C-b> coc#float#has_scroll() ? coc#float#scroll(0) : "\<C-b>"
inoremap <silent><nowait><expr> <C-f> coc#float#has_scroll() ? "\<c-r>=coc#float#scroll(1)\<cr>" : "\<Right>"
inoremap <silent><nowait><expr> <C-b> coc#float#has_scroll() ? "\<c-r>=coc#float#scroll(0)\<cr>" : "\<Left>"
vnoremap <silent><nowait><expr> <C-f> coc#float#has_scroll() ? coc#float#scroll(1) : "\<C-f>"
vnoremap <silent><nowait><expr> <C-b> coc#float#has_scroll() ? coc#float#scroll(0) : "\<C-b>"

" Actions.
nmap <silent> <Space>r <Plug>(coc-rename)
nmap <silent> <Space>a <Plug>(coc-codeaction-cursor)
xmap <silent> <Space>a <Plug>(coc-codeaction-selected)
nmap <silent> <Space>q <Plug>(coc-fix-current)
nmap <silent> <Space>l <Plug>(coc-codelens-action)

nmap <silent> gl <Plug>(coc-openlink)

nmap <Leader>F <Plug>(coc-format)
xmap <Leader>F <Plug>(coc-format-selected)

" Hover.
nnoremap <silent> <Space><Space> <Cmd>call CocActionAsync('doHover')<CR>
nnoremap <silent> <Space>d <Cmd>call CocActionAsync('definitionHover')<CR>

" CoCList.
nnoremap <silent><nowait> <Leader>fd  <Cmd>CocList diagnostics<CR>
nnoremap <silent><nowait> <Leader>fc  <Cmd>CocList commands<CR>
nnoremap <silent><nowait> <Leader>fo  <Cmd>CocList outline<CR>
" Workspace symbols.
nnoremap <silent><nowait> <Leader>fs  <Cmd>CocList -I symbols<CR>
" Resume latest coc list.
nnoremap <silent><nowait> <Leader>fp  <Cmd>CocListResume<CR>

augroup coc_autocmd
  autocmd!
  " Highlight the symbol and its references when holding the cursor.
  autocmd CursorHold * silent call CocActionAsync('highlight')
  " Setup formatexpr specified filetype(s).
  autocmd FileType typescript,json setl formatexpr=CocAction('formatSelected')
  " Update signature help on jump placeholder.
  autocmd User CocJumpPlaceholder call CocActionAsync('showSignatureHelp')
augroup end

" Additional highlighting.
highlight! link CocSemAsync Conditional
highlight! link CocSemControlFlow Conditional
highlight! link CocSemDocumentation SpecialComment
highlight! link CocSemLifetime Label
highlight! link CocSemEnum Constant
highlight! link CocSemEnumMember Constant

highlight! link CocSemBuiltin @variable.builtin
highlight! link CocSemBuiltinConstant @constant.builtin
highlight! link CocSemBuiltinFunction @function.builtin
highlight! link CocSemBuiltinNamespace @namespace.builtin
highlight! link CocSemBuiltinType @type.builtin
highlight! link CocSemConstant Constant

execute "highlight CocSemWithAttribute gui=underline guifg="..synIDattr(hlID('@field'), 'fg')

" vim:shiftwidth=2:softtabstop=2:expandtab
