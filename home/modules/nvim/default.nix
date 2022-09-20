{ lib, pkgs, inputs, my, ... }:
let
  withConf = plugin: config: { inherit plugin config; };

  plugins = with pkgs.vimPlugins; [
    vim-nix # For word recognition.

    # Commen dependencies.
    vim-repeat
    plenary-nvim

    (withConf hop-nvim /* vim */ ''
      lua require('hop').setup()
      nnoremap gw <cmd>HopWord<cr>
      nnoremap gf <cmd>HopChar1<cr>
      nnoremap g/ <cmd>HopPattern<cr>
    '')

    (withConf fcitx-vim ''
      let g:fcitx5_remote = '${lib.getBin pkgs.fcitx5}/bin/fcitx5-remote'
    '')

    # fzf.vim {{{
    (withConf fzf-vim /* vim */ ''
      let $FZF_DEFAULT_COMMAND = '${lib.getBin pkgs.fd}/bin/fd --type=f --hidden --exclude=.git'
      let $FZF_DEFAULT_OPTS = '${lib.concatStringsSep " " [
        "--layout=reverse" # Top-first.
        "--color=16" # 16-color theme.
        "--info=inline"
        "--bind=ctrl-p:up,ctrl-n:down,up:previous-history,down:next-history,alt-p:toggle-preview,alt-a:select-all"
        "--exact" # Substring matching by default, `'`-quote for subsequence matching.
      ]}'
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

      function FZFRg(pat, args, fullscreen)
        let args = "--column --line-number --no-heading --color=always " . a:args
        call fzf#vim#grep("rg " . args . " -- " . shellescape(a:pat), 1, fzf#vim#with_preview(), a:fullscreen)
      endfunction
      command -nargs=1 -bang RgF call FZFRg(<q-args>, "--fixed-strings", <bang>0)
      nnoremap <silent> <leader>ff <cmd>call fzf#vim#files("", fzf#vim#with_preview(), 0)<cr>
      nnoremap <silent> <leader>f. <cmd>call fzf#vim#files(expand('%:h'), fzf#vim#with_preview(), 0)<cr>
      nnoremap <silent> <leader>fp <cmd>call fzf#vim#files(expand('%:h:h'), fzf#vim#with_preview(), 0)<cr>
      nnoremap <silent> <leader>fw <cmd>call FZFRg(expand('<cword>'), '--fixed-strings --word-regexp', 0)<cr>
      nnoremap <silent> <leader>fb <cmd>Buffers<cr>
      nnoremap <silent> <leader>fh <cmd>Helptags<cr>
      nnoremap          <leader>fr :Rg<space>
    '')
    (withConf fzf-lsp-nvim ''
      nnoremap <silent> <leader>fd <cmd>DiagnosticsAll<cr>
      nnoremap <silent> <leader>fs <cmd>DocumentSymbols<cr>
    '')
    # }}}

    (withConf gitsigns-nvim /* vim */ ''
      lua <<EOF
        require('gitsigns').setup {
          on_attach = function(bufnr)
            local gs = package.loaded.gitsigns

            local function map(mode, l, r, opts)
              opts = opts or {}
              opts.buffer = bufnr
              vim.keymap.set(mode, l, r, opts)
            end

            -- Navigation
            map('n', ']c', function()
              if vim.wo.diff then return ']c' end
              vim.schedule(function() gs.next_hunk() end)
              return '<Ignore>'
            end, {expr=true})

            map('n', '[c', function()
              if vim.wo.diff then return '[c' end
              vim.schedule(function() gs.prev_hunk() end)
              return '<Ignore>'
            end, {expr=true})

            -- Actions
            map({'n', 'v'}, '<leader>hs', '<cmd>Gitsigns stage_hunk<CR>')
            map({'n', 'v'}, '<leader>hr', '<cmd>Gitsigns reset_hunk<CR>')
            -- map('n', '<leader>hS', gs.stage_buffer)
            map('n', '<leader>hu', gs.undo_stage_hunk)
            -- map('n', '<leader>hR', gs.reset_buffer)
            map('n', '<leader>hp', gs.preview_hunk)
            -- map('n', '<leader>hb', function() gs.blame_line{full=true} end)
            map('n', '<leader>tb', gs.toggle_current_line_blame)
            map('n', '<leader>hd', gs.diffthis)
            map('n', '<leader>hD', function() gs.diffthis('~') end)
            -- map('n', '<leader>td', gs.toggle_deleted)

            -- Text object
            map({'o', 'x'}, 'ih', ':<C-U>Gitsigns select_hunk<CR>')
          end
        }
      EOF
    '')

    markdown-preview-nvim

    (withConf nerdcommenter ''
      let g:NERDCreateDefaultMappings = 1
      let g:NERDSpaceDelims = 1
      let g:NERDDefaultAlign = 'left'
      let g:NERDCommentEmptyLines = 1
      let g:NERDTrimTrailingWhitespace = 1
    '')


    # Don't search for neighbor files. Just detect the file itself.
    (withConf sleuth ''
      let g:sleuth_neighbor_limit = 0
    '')

    # Disables key mappings.
    (withConf vim-better-whitespace ''
      let g:show_spaces_that_precede_tabs = 1
    '')

    # Immediate refresh & manual define highlighting in nightfox.
    (withConf vim-cursorword ''
      let g:cursorword_delay = 0
      let g:cursorword_highlight = 0
    '')

    (withConf vim-fugitive ''
      command -nargs=* GG tab Git <args>
      command -nargs=* GL tab Git log --max-count=500 <args>
    '')

    # Open remote URL for GitHub & GitLab.
    fugitive-gitlab-vim
    vim-rhubarb

    # vim-sandwich
    (withConf vim-sandwich /* vim */ ''
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
    '')

    (withConf vim-smoothie ''
      let g:smoothie_speed_linear_factor = 20
    '')

    # nvim-cmp {{{
    # https://github.com/neovim/nvim-lspconfig/wiki/Autocompletion
    (withConf luasnip ''
      smap <silent> <tab>   <Plug>luasnip-jump-next
      smap <silent> <m-tab> <Plug>luasnip-jump-next
      smap <silent> <s-tab> <Plug>luasnip-jump-prev
      imap <silent> <m-tab> <Plug>luasnip-jump-next
      imap <silent> <s-tab> <Plug>luasnip-jump-prev
    '')
    cmp_luasnip
    cmp-nvim-lsp
    cmp-path
    cmp-buffer
    (withConf crates-nvim /* vim */ ''
      autocmd BufRead Cargo.toml lua require('crates').setup()
    '')
    (withConf nvim-cmp /* vim */ ''
      lua <<EOF
        vim.o.completeopt = 'menuone,noselect'

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
    '')
    # }}}

    # LSP {{{
    lsp_signature-nvim
    my.pkgs.lsp-inlayhints-nvim

    (withConf lsp-status-nvim /* vim */ ''
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
    '')

    (withConf nvim-lspconfig /* vim */ ''
      lua <<EOF
        local lsp = require('lspconfig')

        local lsp_status = require('lsp-status')
        local lsp_inlayhints = require('lsp-inlayhints')
        lsp_inlayhints.setup {
          inlay_hints = {
            parameter_hints = { show = false },
            highlight = 'Comment',
          },
        }

        -- https://github.com/neovim/nvim-lspconfig/wiki/Autocompletion
        local capabilities = vim.lsp.protocol.make_client_capabilities()
        capabilities = require('cmp_nvim_lsp').update_capabilities(capabilities)
        vim.list_extend(capabilities, lsp_status.capabilities)

        local function on_attach(client, bufnr)
          lsp_status.on_attach(client, bufnr)
          lsp_inlayhints.on_attach(bufnr, client)
          require("lsp_signature").on_attach()

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
        end

        -- This is set globally and only affect the current buffer.
        vim.api.nvim_create_user_command('Format', function() vim.lsp.buf.formatting_sync() end, {})

        lsp.rust_analyzer.setup {
          autostart = false, -- FIXME: It would try to start LSP in crates.io pkgs and produces warnings.
          on_attach = on_attach,
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
          on_attach = on_attach,
          capabilities = capabilities,
        }

        lsp.nil_ls.setup {
          autostart = true,
          on_attach = on_attach,
          capabilities = capabilities,
        }
      EOF
    '')
    # }}}

    # Tree sitter. {{{
    (let
      inherit (my.pkgs) tree-sitter-bash tree-sitter-nix;
      plugins = ps: with ps; with my.pkgs; [
        tree-sitter-agda
        tree-sitter-bash
        tree-sitter-beancount
        tree-sitter-c
        tree-sitter-clojure
        tree-sitter-cmake
        tree-sitter-commonlisp
        tree-sitter-cpp
        tree-sitter-css
        tree-sitter-dockerfile
        tree-sitter-glsl
        tree-sitter-go
        tree-sitter-gomod
        tree-sitter-haskell
        tree-sitter-html
        tree-sitter-java
        tree-sitter-javascript
        tree-sitter-json
        tree-sitter-latex
        tree-sitter-llvm
        tree-sitter-lua
        tree-sitter-make
        # tree-sitter-markdown # Highly broken
        tree-sitter-nix
        tree-sitter-perl
        tree-sitter-python
        tree-sitter-query
        tree-sitter-regex
        tree-sitter-rst
        tree-sitter-rust
        tree-sitter-toml
        tree-sitter-tsx
        tree-sitter-typescript
        tree-sitter-vim
        tree-sitter-yaml
      ];

      nvim-treesitter = (pkgs.vimPlugins.nvim-treesitter.withPlugins plugins).overrideAttrs (old: {
        postInstall = old.postInstall or "" + ''
          for x in highlights locals injections indents; do
            cp -f ${tree-sitter-nix}/queries/nvim-$x.scm $out/queries/nix/$x.scm
          done
        '';
      });
    in {
      plugin = nvim-treesitter;
      # vim
      config = ''
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
            refactor = {
              highlight_definition = { enable = true },
              navigation = {
                enable = true,
                keymaps = {
                  goto_definition = "gnd",
                  list_definitions = "gnD",
                  list_definitions_toc = "gO",
                  goto_next_usage = "<a-*>",
                  goto_previous_usage = "<a-#>",
                },
              },
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
                init_selection = "\\[",
                node_incremental = "\\[",
                node_decremental = "\\]",
                scope_incremental = "\\{",
              },
            },
          }
        EOF
      '';
    })
    # }}}

    nvim-treesitter-context
    nvim-treesitter-refactor
    nvim-treesitter-textobjects
    playground

    # nightfox-nvim {{{
    (withConf nightfox-nvim /* vim */ ''
      lua <<EOF
        require("nightfox").setup {
          modules = {
            cmp = true,
            diagnostic = true,
            gitsigns = true,
            hop = true,
            native_lsp = true,
            treesitter = true,
          },
          groups = {
            all = {
              -- vim-better-whitespace
              ExtraWhitespace = { bg = "palette.red.dim" },

              -- vim-cursorword
              CursorWord0 = { style = "underline" },
              CursorWord1 = { style = "underline" },

              DiagnosticUnderlineHint = { link = "None" },
            },
          },
        }

        if vim.env.COLORTERM ~= nil then
          vim.cmd('colorscheme nightfox')
        end
      EOF
    '')
    # }}}
  ];

  # extraConfig {{{
  extraConfig = /* vim */ ''
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
    set softtabstop=4
    set expandtab
    set ttimeoutlen=1

    " Render.
    set number
    set cursorline
    set signcolumn=yes " Always show.
    set list
    set listchars=tab:-->,extends:>,precedes:<

    " Highlight on yank.
    autocmd TextYankPost * silent! lua vim.highlight.on_yank {higroup="IncSearch", timeout=200}
    " Copy to clipboard on yank.
    autocmd TextYankPost * if v:event["operator"] == "y" && v:event["regname"] == "" | let @+ = @0 | endif

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

    " Mapping.

    let g:mapleader='\'

    " Command-like.
    noremap  <m-z> <cmd>set wrap!<bar>set wrap?<cr>
    noremap  <m-cr> <cmd>set hlsearch!<bar>set hlsearch?<cr>

    " Panes
    noremap <c-w>v <cmd>vsplit<cr>
    noremap <c-w>s <cmd>split<cr>
    noremap <c-w>+ <c-w>+<c-w>+<c-w>+<c-w>+<c-w>+
    noremap <c-w>- <c-w>-<c-w>-<c-w>-<c-w>-<c-w>-
    noremap <c-w><lt> <c-w><lt><c-w><lt><c-w><lt><c-w><lt><c-w><lt>
    noremap <c-w>> <c-w>><c-w>><c-w>><c-w>><c-w>>

    " Commands.

    command -nargs=0 Sudow w !sudo tee % >/dev/null
    command -nargs=* W w <args>
  '';
  # }}}

in
{
  programs.neovim = {
    enable = true;
    withRuby = false;
    inherit plugins extraConfig;
  };

  home.sessionVariables.EDITOR = "nvim";

  # Use default LSP `cmd` from PATH to allow overriding.
  home.packages = with pkgs; [
    pyright
    rust-analyzer
    inputs.nil.packages.${pkgs.system}.nil
  ];
}
