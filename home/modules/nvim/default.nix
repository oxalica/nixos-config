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
      nmap gw <Cmd>HopWord<CR>
      nmap gf <Cmd>HopChar1<CR>
      nmap g/ <Cmd>HopPattern<CR>
    '')

    fcitx-vim

    # fzf.vim {{{
    (withConf fzf-vim /* vim */ ''
      let $FZF_DEFAULT_COMMAND = '${lib.getBin pkgs.fd}/bin/fd --type=f --hidden --no-ignore-vcs --exclude=.git'
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
    '')
    (withConf fzf-lsp-nvim /* vim */ ''
      nmap <Leader>fd <Cmd>DiagnosticsAll<CR>
      nmap <Leader>fs <Cmd>DocumentSymbols<CR>
    '')
    # }}}

    gitgutter

    markdown-preview-nvim

    (withConf nerdcommenter ''
      let g:NERDCreateDefaultMappings = 1
      let g:NERDSpaceDelims = 1
      let g:NERDDefaultAlign = 'left'
      let g:NERDCommentEmptyLines = 1
      let g:NERDTrimTrailingWhitespace = 1
    '')

    sleuth

    (withConf vim-better-whitespace ''
      let g:show_spaces_that_precede_tabs = 1
    '')

    vim-illuminate

    (withConf vim-fugitive /* vim */ ''
      nmap <F2> <Cmd>tab Git<CR>
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

    # Should be setup early, or it cannot trigger autocmd inside autocmd.
    (withConf crates-nvim /* vim */ ''
      lua require('crates').setup()
    '')

    # nvim-cmp {{{
    # https://github.com/neovim/nvim-lspconfig/wiki/Autocompletion
    (withConf luasnip /* vim */ ''
      smap <Tab>   <Plug>luasnip-jump-next
      smap <M-Tab> <Plug>luasnip-jump-next
      smap <S-Tab> <Plug>luasnip-jump-prev
      imap <M-Tab> <Plug>luasnip-jump-next
      imap <S-Tab> <Plug>luasnip-jump-prev
    '')
    cmp_luasnip
    cmp-nvim-lsp
    cmp-path
    cmp-buffer
    (withConf nvim-cmp /* vim */ ''
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
    '')
    # }}}

    # LSP {{{
    lsp_signature-nvim
    lsp-inlayhints-nvim

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
          lsp_inlayhints.on_attach(client, bufnr)
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
      '';
    })
    # }}}

    (withConf nvim-treesitter-context /* vim */ ''
      lua <<EOF
        require('treesitter-context').setup {
          max_lines = 3,
          trim_scope = 'inner',
        }
      EOF
    '')
    nvim-treesitter-textobjects
    playground

    # nightfox-nvim {{{
    (withConf nightfox-nvim /* vim */ ''
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
    '')
    # }}}
  ];

in
{
  programs.neovim = {
    enable = true;
    withRuby = false;
    inherit plugins;
    extraConfig = builtins.readFile ./vimrc.vim;
  };

  home.sessionVariables.EDITOR = "nvim";

  # Use default LSP `cmd` from PATH to allow overriding.
  home.packages = with pkgs; [
    pyright
    rust-analyzer
    nil
  ];
}
