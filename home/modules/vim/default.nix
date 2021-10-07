{ lib, pkgs, inputs, ... }:
let
  plugins = with pkgs.vimPlugins; [
    # Functional extension.
    auto-pairs
    easymotion
    fcitx-vim
    fzf-vim
    nerdcommenter
    tabular
    vim-better-whitespace
    vim-cursorword
    vim-fugitive
    vim-gitgutter
    vim-highlightedyank
    vim-matchup
    vim-sandwich
    vim-smoothie

    # Plugins of plugins.
    fugitive-gitlab-vim
    vim-rhubarb # GitHub support for vim-fugitive.

    # File types.
    jsonc-vim
    markdown-preview-nvim
    # rust-vim
    vim-beancount
    vim-glsl
    vim-markdown
    vim-nix
    vim-toml
    (pkgs.vimUtils.buildVimPlugin {
      pname = "rust-vim";
      version = "2021-08-18";
      # Advanced type highlighting: https://github.com/rust-lang/rust.vim/pull/431
      src = pkgs.fetchFromGitHub {
        owner = "Iron-E";
        repo = "rust.vim";
        rev = "dd8fcd5be9a0d8b83dc1515974959f6c92881d8d";
        hash = "sha256-qPN/dfKKEKSqeKT7cHrJvyx8sZMziJm0QS8kTIQC13Q=";
      };
    })

    # Color scheme.
    (pkgs.vimUtils.buildVimPlugin {
      pname = "nightfox-nvim";
      version = "fixed";
      src = inputs.nightfox-vim;
    })
  ];

  vimPlugins = with pkgs.vimPlugins; [
  ];

  nvimPlugins = with pkgs.vimPlugins; [
    # LSP.
    coc-nvim
    coc-rust-analyzer

    # Tree sitter.
    {
      plugin = let
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
          version = "master";
          src = inputs.nvim-treesitter;
          postInstall = old.postInstall or "" + ''
            for x in highlights locals; do
              cp -f ${inputs.tree-sitter-nix}/queries/nvim-$x.scm $out/queries/nix/$x.scm
            done
          '';
        });
      in
        nvim-treesitter;

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
          }
        EOF
      '';
    }
    nvim-treesitter-context
    nvim-treesitter-refactor
    nvim-treesitter-textobjects
    playground
  ];

  extraConfig =
    lib.replaceStrings
      [ "@@fcitx5-remote@@" ]
      [ "${lib.getBin pkgs.fcitx5}/bin/fcitx5-remote" ]
      (builtins.readFile ./init.vim);

in
{
  programs.vim = {
    enable = true;
    plugins = plugins ++ vimPlugins;
    inherit extraConfig;
  };

  programs.neovim = {
    enable = true;
    plugins = plugins ++ nvimPlugins;
    inherit extraConfig;

    coc.enable = true;
    coc.settings = {
      "rust-analyzer.server.path" = "${pkgs.rust-analyzer}/bin/rust-analyzer";
    };
  };
}
