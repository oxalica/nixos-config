{ lib, pkgs, inputs, ... }:
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

    # telescope {{{
    telescope-fzf-native-nvim
    (withConf telescope-nvim /* vim */ ''
      lua <<EOF
        require("telescope").setup {
          defaults = {
            mappings = {
              i = {
                ["<m-p>"] = require("telescope.actions.layout").toggle_preview,
                ["<esc>"] = require("telescope.actions").close,
                ["<up>"] = require("telescope.actions").cycle_history_prev,
                ["<down>"] = require("telescope.actions").cycle_history_next,
              },
            },
            sorting_strategy = "ascending",
            layout_strategy = "horizontal",
            layout_config = { prompt_position = "top" },
            preview = {
              filesize_limit = 1, -- 1MiB
              msg_bg_fillchar = ".",
              hide_on_startup = false,
            },
          },
          extensions = {
            fzf = { fuzzy = false }, -- Substring matching by default.
          },
          pickers = {
            find_files = {
              -- Search hidden files.
              find_command = { "fd", "--hidden", "--type=file", "--exclude=.git" },
            },
          },
        }
        require('telescope').load_extension('fzf')

        vim.api.nvim_create_user_command("Rg", function(args)
          require('telescope.builtin').grep_string {
            use_regex = not args.bang,
            search = args.args,
          }
        end, { nargs = 1, bang = true })
      EOF

      nnoremap <leader>ff <cmd>Telescope find_files<cr>
      nnoremap <leader>f. <cmd>Telescope find_files cwd=%:h<cr>
      nnoremap <leader>fp <cmd>Telescope find_files cwd=%:h:h<cr>

      nnoremap <leader>fr <cmd>Telescope live_grep<cr>
      nnoremap <leader>fw <cmd>Telescope grep_string<cr>
      nnoremap <leader>fb <cmd>Telescope buffers<cr>
      nnoremap <leader>fh <cmd>Telescope help_tags<cr>
      nnoremap <leader>ft <cmd>Telescope treesitter<cr>
      nnoremap <leader>fd <cmd>Telescope diagnostics<cr>
      nnoremap <leader>fa <cmd>Telescope lsp_workspace_symbols<cr>
      nnoremap <leader>fs <cmd>Telescope lsp_document_symbols<cr>
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
    luasnip
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
          cmd = { '${pkgs.rust-analyzer}/bin/rust-analyzer' },
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
          cmd = { '${pkgs.pyright}/bin/pyright-langserver', '--stdio' },
        }

        lsp.rnix.setup {
          autostart = true,
          capabilities = capabilities,
          cmd = { '${pkgs.rnix-lsp}/bin/rnix-lsp' },
        }
      EOF
    '')
    # }}}

    # Tree sitter. {{{
    (let
      plugins = ps: with ps; [
        tree-sitter-agda
        (tree-sitter-bash.overrideAttrs (old: {
          version = "fixed";
          src = inputs.tree-sitter-bash;
        }))
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
        (tree-sitter-nix.overrideAttrs (old: {
          version = "fixed";
          src = inputs.tree-sitter-nix;
        }))
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
          groups = {
            all = {
              -- vim-better-whitespace
              ExtraWhitespace = { bg = "palette.red.dim" },

              -- vim-cursorword
              CursorWord0 = { style = "underline" },
              CursorWord1 = { style = "underline" },
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
}
