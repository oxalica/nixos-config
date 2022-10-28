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

" plugin: fzf-lsp-nvim {{{
nmap <Leader>fd <Cmd>DiagnosticsAll<CR>
nmap <Leader>fs <Cmd>DocumentSymbols<CR>
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

" plugin: vim-illuminate

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

" plugin: vim-smoothie {{{
let g:smoothie_speed_linear_factor = 20
"}}}

" plugin: crates-nvim {{{
" Should be setup early, or it cannot trigger autocmd inside autocmd.
lua require('crates').setup()
"}}}

" plugin: nvim-cmp {{{

" Reference: https://github.com/neovim/nvim-lspconfig/wiki/Autocompletion

" plugin: luasnip {{{
smap <Tab>   <Plug>luasnip-jump-next
smap <M-Tab> <Plug>luasnip-jump-next
smap <S-Tab> <Plug>luasnip-jump-prev
imap <M-Tab> <Plug>luasnip-jump-next
imap <S-Tab> <Plug>luasnip-jump-prev
"}}}
" plugin: cmp_luasnip
" plugin: cmp-nvim-lsp
" plugin: cmp-path
" plugin: cmp-buffer

set completeopt=menu,menuone,noselect
lua <<EOF
  local cmp = require('cmp')
  local luasnip = require('luasnip')
  cmp.setup {
    -- REQUIRED - you must specify a snippet engine
    snippet = {
      expand = function(args)
        luasnip.lsp_expand(args.body)
      end,
    },
    mapping = {
      ['<C-p>'] = cmp.mapping.select_prev_item(),
      ['<C-n>'] = cmp.mapping.select_next_item(),
      ['<C-d>'] = cmp.mapping.scroll_docs(-4),
      ['<C-f>'] = cmp.mapping.scroll_docs(4),
      ['<C-space>'] = cmp.mapping.complete(),
      ['<C-e>'] = cmp.mapping.close(),
      ['<tab>'] = cmp.mapping(function(fallback)
        if cmp.visible() then
          cmp.confirm { select = true }
        else
          fallback()
        end
      end),
    },
    sources = cmp.config.sources({
      { name = 'nvim_lsp' },
      { name = 'luasnip' },
      { name = 'crates' },
    }, {
      { name = 'path' },
      { name = 'buffer' },
    }),
    sorting = {
      comparators = {
        cmp.config.compare.sort_text, -- From LSP.
        cmp.config.compare.recently_used,
        cmp.config.compare.offset, -- Start position of the completion.
      },
    },
  }
EOF

"}}}

" plugin: nvim-lspconfig {{{
" plugin: lsp_signature-nvim
" plugin: lsp-inlayhints-nvim
" plugin: lsp-status-nvim {{{
lua <<EOF
  local lsp_status = require('lsp-status')
  lsp_status.config {
    status_symbol = '[LSP]',
    indicator_errors = '⮾ ',
    indicator_warnings = '⚠ ',
    indicator_info = '🛈 ',
    indicator_hint = ' ',
    indicator_separator = "",
    component_separator = ' ',
  }
  lsp_status.register_progress()
EOF
"}}}

" This is set globally and only affect the current buffer.
command! -nargs=0 Format lua vim.lsp.buf.formatting_sync()

lua <<EOF
  local lsp = require('lspconfig')

  local lsp_status = require('lsp-status')
  local lsp_inlayhints = require('lsp-inlayhints')
  local lsp_signature = require('lsp_signature')

  lsp_inlayhints.setup {
    inlay_hints = {
      parameter_hints = { show = false },
      highlight = 'Comment',
    },
  }

  -- https://github.com/neovim/nvim-lspconfig/wiki/Autocompletion
  local capabilities = vim.tbl_extend(
    'keep',
    require('cmp_nvim_lsp').default_capabilities(),
    lsp_status.capabilities
  );

  vim.api.nvim_create_autocmd('LspAttach', {
    callback = function(args)
      local bufnr = args.buf
      local client = vim.lsp.get_client_by_id(args.data.client_id)
      lsp_status.on_attach(client, bufnr)
      lsp_inlayhints.on_attach(client, bufnr)
      lsp_signature.on_attach(client)

      local mappings = {
        { 'gD', vim.lsp.buf.declaration },
        { 'gd', vim.lsp.buf.definition },
        { 'gi', vim.lsp.buf.implementation },
        { 'gy', vim.lsp.buf.type_definition },
        { 'gr', vim.lsp.buf.references },
        { '[d', vim.diagnostic.goto_prev },
        { ']d', vim.diagnostic.goto_next },
        { '  ', vim.lsp.buf.hover },
        { ' s', vim.lsp.buf.signature_help },
        { ' r', vim.lsp.buf.rename },
        { ' a', vim.lsp.buf.code_action },
        { ' d', vim.diagnostic.open_float },
        { ' q', vim.diagnostic.setloclist },
      }
      for i, m in pairs(mappings) do
        vim.keymap.set('n', m[1], function() m[2]() end, { buffer = bufnr })
      end
    end,
  })

  lsp.rust_analyzer.setup {
    autostart = false, -- FIXME: It would try to start LSP in crates.io pkgs and produces warnings.
    capabilities = capabilities,
    settings = {
      ['rust-analyzer'] = {
        checkOnSave = { command = 'clippy' },
        assist = {
          importEnforceGranularity = true,
          importGranularity = 'module',
        },
        completion = {
          autoself = { enable = false },
          postfix = { enable = false },
          addCallArgumentSnippets = false,
          snippets = {},
        },
      },
    },
  }

  lsp.pyright.setup {
    autostart = true,
    capabilities = capabilities,
  }

  lsp.nil_ls.setup {
    autostart = true,
    capabilities = capabilities,
  }

  lsp.tsserver.setup {
    autostart = true,
    capabilities = capabilities,
    cmd = { 'typescript-language-server', '--stdio', '--tsserver-path=tsserver' },
  }
EOF
"}}}

" plugin: nvim-treesitter {{{
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
    textobjects = {
      select = {
        enable = true,
        keymaps = {
          ["af"] = "@function.outer",
          ["if"] = "@function.inner",
          ["ac"] = "@class.outer",
          ["ic"] = "@class.inner",
        },
      },
      move = {
        enable = true,
        goto_next_start = {
          ["]f"] = "@function.outer",
          ["]b"] = "@block.outer",
          ["]]"] = "@class.outer",
        },
        goto_previous_start = {
          ["[f"] = "@function.outer",
          ["[b"] = "@block.outer",
          ["[["] = "@class.outer",
        },
      },
    },
    incremental_selection = {
      enable = true,
      keymaps = {
        init_selection = "<C-s>",
        node_incremental = "<C-s>",
        -- C-S-s doesn't work for alacritty.
        node_decremental = "<C-x>",
      },
    },
  }
EOF

" plugin: nvim-treesitter-context {{{
lua <<EOF
  require('treesitter-context').setup {
    max_lines = 3,
    trim_scope = 'inner',
  }
EOF
"}}}

" plugin: nvim-treesitter-textobjects

" plugin: playground

"}}}

" plugin: nightfox-nvim {{{
lua <<EOF
  require("nightfox").setup {
    modules = {
      cmp = true,
      diagnostic = true,
      hop = true,
      illuminate = true,
      native_lsp = true,
      treesitter = true,
    },
    groups = {
      all = {
        -- vim-better-whitespace
        ExtraWhitespace = { bg = "palette.red.dim" },

        DiagnosticUnderlineHint = { link = "None" },

        -- Somehow not set by default.
        IlluminatedWordText = { link = "LspReferenceText" },
        IlluminatedWordRead = { link = "LspReferenceRead" },
        IlluminatedWordWrite = { link = "LspReferenceWrite" },
      },
    },
  }

  if vim.env.TMUX ~= nil or vim.env.COLORTERM ~= nil then
    vim.cmd('colorscheme nightfox')
  end
EOF
"}}}
" vim:shiftwidth=2:softtabstop=2:expandtab
