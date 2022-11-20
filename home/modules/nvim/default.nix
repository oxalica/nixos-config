{ lib, pkgs, inputs, my, ... }:
let
  vimPlugins = pkgs.vimPlugins // {
    nvim-treesitter = pkgs.vimPlugins.nvim-treesitter.withAllGrammars;
  };

  vimrc = builtins.readFile ./vimrc.vim;
  plugins =
    map (x: vimPlugins.${lib.elemAt x 0})
      (lib.filter (x: lib.isList x)
        (builtins.split ''" plugin: ([A-Za-z_-]+)'' vimrc));

in
{
  programs.neovim = {
    enable = true;
    withRuby = false;
    inherit plugins;
    extraConfig = vimrc;
  };

  home.sessionVariables.EDITOR = "nvim";

  # Use default LSP `cmd` from PATH to allow overriding.
  home.packages = with pkgs; [
    pyright
    rust-analyzer
    nil
    nodePackages.typescript
    nodePackages.typescript-language-server
  ];
}
