{ lib, pkgs, ... }:
let
  plugins = with pkgs.vimPlugins; [
    # Edit & navigate.
    easymotion
    # fcitx-vim
    fzf-vim
    nerdcommenter
    vim-cursorword
    vim-gitgutter
    vim-highlightedyank
    vim-sandwich
    # FIXME
    (fcitx-vim.overrideAttrs (old: {
      version = "2021-08-20";
      src = pkgs.fetchFromGitHub {
        owner = "lilydjwg";
        repo = "fcitx.vim";
        rev = "3554b279a09f0edf31129ad162613e5954097fd0";
        hash = "sha256-kIHPbtmOnttxzJwd8e1L0Lb8It0d+KgrtIQswzX1Eq4=";
      };
    }))

    # File types.
    rust-vim
    vim-beancount
    vim-nix
    vim-toml

    # LSP.
    coc-nvim
    coc-rust-analyzer

    # Color scheme.
    (pkgs.vimUtils.buildVimPlugin {
      name = "lilypink";
      src = ./lilypink;
    })
  ];

  extraConfig =
    lib.replaceStrings
      [ "@@fcitx5@@" "@@fd@@" ]
      (with pkgs; map (p: toString (lib.getBin p))
        [ fcitx5 fd ])
      (builtins.readFile ./init.vim);

in
{
  programs.vim = {
    enable = true;
    inherit extraConfig plugins;
  };

  programs.neovim = {
    enable = true;
    inherit extraConfig plugins;

    coc.enable = true;
    coc.settings = {
      "rust-analyzer.server.path" = "${pkgs.rust-analyzer}/bin/rust-analyzer";
    };
  };
}
