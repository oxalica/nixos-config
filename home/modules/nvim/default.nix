{ lib, pkgs, inputs, ... }:
let
  withConf = plugin: config: { inherit plugin config; };

  plugins = with pkgs.vimPlugins; [
    vim-nix # For word recognition.

    easymotion

    (withConf fcitx-vim ''
      let g:fcitx5_remote = '${lib.getBin pkgs.fcitx5}/bin/fcitx5-remote'
    '')

    # fzf-vim {{{
    (withConf fzf-vim /* vim */ ''
      lua vim.g.fzf_history_dir = (vim.env.XDG_STATE_HOME or vim.env.HOME .. '/.local/state') .. '/fzf.vim/history'
      let g:fzf_action = {
          \ 'ctrl-t': 'tab split',
          \ 'ctrl-s': 'split',
          \ 'ctrl-v': 'vsplit',
          \ }
      function FzfAt(path, hidden)
        let source = '${lib.getBin pkgs.fd}/bin/fd'
        if a:hidden
          let source .= ' --hidden'
        endif
        let dir = a:path
        if empty(dir)
          let dir = '.'
        endif
        let show_dir = dir
        if len(show_dir) > &columns / 2
          let show_dir = pathshorten(show_dir)
        endif
        let prompt = fnamemodify(getcwd(), ':h') . '/' . show_dir . '/'
        let options = ['--prompt', prompt]
        let opts = { 'dir': a:path, 'source': source, 'options': options }
        call fzf#run(fzf#wrap('files', opts))
      endfunction
      nnoremap <silent> <leader>ff :call FzfAt('.', v:false)<cr>
      nnoremap <silent> <leader>fh :call FzfAt('.', v:true)<cr>
      nnoremap <silent> <leader>f. :call FzfAt(expand('%:h'), v:false)<cr>
      nnoremap <silent> <leader>fp :call FzfAt(expand('%:h:h'), v:false)<cr>
      " Fullscreen by default for :Rg
      command! -nargs=1 Rg call fzf#vim#grep("rg --column --line-number --no-heading --color=always --smart-case -- ".shellescape(<q-args>), 1, fzf#vim#with_preview(), 1)
    '')
    # }}}

    (withConf gitsigns-nvim ''
      lua require('gitsigns').setup()
    '')

    markdown-preview-nvim

    (withConf nerdcommenter ''
      let g:NERDSpaceDelims = 1
      let g:NERDDefaultAlign = 'left'
      let g:NERDCommentEmptyLines = 1
    '')

    # Don't search for neighbor files. Just detect the file itself.
    (withConf sleuth ''
      let g:sleuth_neighbor_limit = 0
    '')

    # Disables key mappings.
    (withConf vim-better-whitespace ''
      let g:show_spaces_that_precede_tabs = 1
      let g:better_whitespace_operator = 1
    '')

    (withConf vim-crates ''
      highlight link Crates WarningMsg
      autocmd BufNewFile,BufRead Cargo.toml call crates#toggle()
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

    (withConf vim-highlightedyank ''
      let g:highlightedyank_highlight_duration = 200
    '')

    vim-repeat

    # vim-sandwich {{{
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
    # }}}

    (withConf vim-smoothie ''
      let g:smoothie_speed_linear_factor = 20
    '')

    # nvim-cmp {{{
    # https://github.com/neovim/nvim-lspconfig/wiki/Autocompletion
    (luasnip.overrideAttrs (old: {
      version = "master";
      src = inputs.luasnip;
    }))
    cmp_luasnip
    cmp-nvim-lsp
    cmp-path
    cmp-buffer
    (withConf nvim-cmp /* vim */ ''
      lua <<EOF
        vim.o.completeopt = 'menuone,noselect'
        local cmp = require('cmp')
        cmp.setup {
          -- REQUIRED - you must specify a snippet engine
          snippet = {
            expand = function(args)
              require('luasnip').lsp_expand(args.body)
            end,
          },
          mapping = {
            ['<C-p>'] = cmp.mapping.select_prev_item(),
            ['<C-n>'] = cmp.mapping.select_next_item(),
            ['<C-d>'] = cmp.mapping.scroll_docs(-4),
            ['<C-f>'] = cmp.mapping.scroll_docs(4),
            ['<C-space>'] = cmp.mapping.complete(),
            ['<C-e>'] = cmp.mapping.close(),
            ['<tab>'] = cmp.mapping.confirm { select = true },
          },
          sources = cmp.config.sources({
            { name = 'nvim_lsp' },
            { name = 'luasnip' },
          }, {
            { name = 'path' },
            { name = 'buffer' },
          }),
        }
      EOF
    '')
    # }}}

    # LSP {{{
    lsp_signature-nvim

    (withConf lsp-status-nvim /* vim */ ''
      lua <<EOF
        local lsp_status = require('lsp-status')
        lsp_status.config {
          status_symbol = '[LSP]',
          indicator_errors = 'E',
          indicator_warnings = 'W',
          indicator_info = 'I',
          indicator_hint = 'H',
          indicator_ok = 'OK',
        }
        lsp_status.register_progress()
      EOF
    '')

    (withConf lsp_extensions-nvim /* vim */ ''
      lua <<EOF
        function update_inlay_hints()
          require("lsp_extensions").inlay_hints {
            enabled = { "TypeHint", "ChainingHint" },
            prefix = "»",
            highlight = "NonText",
          }
        end
        vim.cmd('autocmd InsertLeave,BufEnter,BufWinEnter,TabEnter,BufWritePost *.rs :lua update_inlay_hints()')
      EOF
    '')

    (withConf nvim-lspconfig /* vim */ ''
      lua <<EOF
        local lsp = require('lspconfig')
        local lsp_mappings = {
          { 'gD', 'vim.lsp.buf.declaration()' },
          { 'gd', 'vim.lsp.buf.definition()' },
          { 'gi', 'vim.lsp.buf.implementation()' },
          { 'gy', 'vim.lsp.buf.type_definition()' },
          { 'gr', 'vim.lsp.buf.references()' },
          { '[d', 'vim.diagnostic.goto_prev()' },
          { ']d', 'vim.diagnostic.goto_next()' },
          { '<space><space>', 'vim.lsp.buf.hover()' },
          { '<space>s', 'vim.lsp.buf.signature_help()' },
          { '<space>r', 'vim.lsp.buf.rename()' },
          { '<space>a', 'vim.lsp.buf.code_action()' },
          { '<space>d', 'vim.diagnostic.open_float()' },
          { '<space>q', 'vim.diagnostic.setloclist()' },
        }

        local lsp_status = require('lsp-status')

        -- https://github.com/neovim/nvim-lspconfig/wiki/Autocompletion
        local capabilities = vim.lsp.protocol.make_client_capabilities()
        capabilities = require('cmp_nvim_lsp').update_capabilities(capabilities)
        vim.list_extend(capabilities, lsp_status.capabilities)

        local function on_attach(client, bufnr)
          lsp_status.on_attach(client, bufnr)
          require("lsp_signature").on_attach()
          for i, lr in pairs(lsp_mappings) do
            vim.api.nvim_buf_set_keymap(bufnr, 'n', lr[1], '<cmd>lua ' .. lr[2] .. '<cr>', { noremap = true, silent = true })
          end
        end

        lsp.rust_analyzer.setup {
          autostart = false,
          on_attach = on_attach,
          capabilities = capabilities,
          cmd = { '${lib.getBin pkgs.rust-analyzer}/bin/rust-analyzer' },
          settings = {
            ['rust-analyzer.checkOnSave.command'] = 'clippy',
            ['rust-analyzer.completion.postfix.enable'] = false,
            ['rust-analyzer.assist.importEnforceGranularity'] = true,
            ['rust-analyzer.assist.importGranularity'] = 'module',
          },
        }
      EOF
    '')
    # }}}

    # Tree sitter. {{{
    (let
      plugins = ps: builtins.attrValues (ps // {
        tree-sitter-nix = ps.tree-sitter-nix.overrideAttrs (old: {
          version = "fixed";
          src = inputs.tree-sitter-nix;
        });
        tree-sitter-bash = ps.tree-sitter-bash.overrideAttrs (old: {
          version = "fixed";
          src = inputs.tree-sitter-bash;
        });
      });
      nvim-treesitter = (pkgs.vimPlugins.nvim-treesitter.withPlugins plugins).overrideAttrs (old: {
        postInstall = old.postInstall or "" + ''
          for x in highlights locals injections indents; do
            cp -f ${inputs.tree-sitter-nix}/queries/nvim-$x.scm $out/queries/nix/$x.scm
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
                init_selection = "gnn",
                node_incremental = "grn",
                scope_incremental = "grc",
                node_decremental = "grm",
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
          fox = "nightfox",
          colors = {
            comment = "#768390", -- From GitHub, to increse contract.
          },
          hlgroups = {
            SpecialKey = { fg = "''${magenta_dm}" },
            NonText = { fg = "#526175" }, -- The original low-contract 'comment' color.

            -- better-whitespace.vim
            ExtraWhitespace = { bg = "''${error}" },

            -- vim-highlightedyank
            HighlightedyankRegion = { bg = "''${bg_search}" },

            -- vim-cursorword
            CursorWord0 = { style = "underline" },
            CursorWord1 = { style = "underline" },
          },
        }

        if vim.env.COLORTERM ~= nil then
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

    extraConfig = ''
      source ${./init.lua}
    '';
  };

  pam.sessionVariables.EDITOR = "nvim";
  home.sessionVariables.EDITOR = "nvim";
}
