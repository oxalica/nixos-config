{ lib, pkgs, ... }:
let
  plugins = with pkgs.vimPlugins; [
    # Edit & navigate.
    easymotion
    fcitx-vim
    fzf-vim
    nerdcommenter
    vim-cursorword
    vim-gitgutter
    vim-highlightedyank
    vim-sandwich
    vim-smoothie

    # File types.
    rust-vim
    vim-beancount
    vim-markdown
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
      [ "@@fcitx5-remote@@" ]
      [ "${lib.getBin pkgs.fcitx5}/bin/fcitx5-remote" ]
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
