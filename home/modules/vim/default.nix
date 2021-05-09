{ pkgs, ... }:
{
  programs.vim = {
    enable = true;
    extraConfig = builtins.readFile ./init.vim;
    plugins = with pkgs.vimPlugins; [
      easymotion
      vim-cursorword
      vim-gitgutter
      vim-nix
      vim-surround
      vim-toml

      (pkgs.callPackage ./fcitx5-vim {})
    ];
  };
}
