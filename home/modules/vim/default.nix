{ pkgs, ... }:
{
  programs.vim = {
    enable = true;
    plugins = with pkgs.vimPlugins; [
      vim-surround
      vim-nix
    ];
    extraConfig = builtins.readFile ./vimrc.vim;
  };
}
