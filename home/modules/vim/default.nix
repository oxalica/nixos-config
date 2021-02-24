{ pkgs, ... }:
{
  programs.vim = {
    enable = true;
    plugins = with pkgs.vimPlugins; [
      vim-nix
      vim-surround
      vim-toml
    ];
    extraConfig = builtins.readFile ./vimrc.vim;
  };
}
