{ lib, pkgs, ... }:
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
    # FIXME: https://nixpk.gs/pr-tracker.html?pr=140634
    (pkgs.vimUtils.buildVimPlugin {
      pname = "nightfox-nvim";
      version = "2021-10-04";
      src = pkgs.fetchFromGitHub {
        owner = "EdenEast";
        repo = "nightfox.nvim";
        rev = "15dfe546111a96e5f30198d5bd163658acdbbe3b";
        hash = "sha256-ZXWo418LxML0WEEJFfdXBY5GxehJ3Es2du5LVyKKAyg=";
      };
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
      plugin = nvim-treesitter.withPlugins (_: pkgs.tree-sitter.allGrammars);
      config = ''
        lua <<EOF
          require("nvim-treesitter.configs").setup {
            highlight = {
              enable = true,
            },
            playground = {
              enable = true,
            },
          }
        EOF
      '';
    }
    nvim-treesitter-context
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
