{ lib, pkgs, ... }:
{
  imports = [
    ./shell.nix
    ./vim.nix
  ];

  environment.systemPackages = with pkgs; [
    tealdeer curl pv htop loop bc file lz4 exa screen git
    (lib.lowPrio vim-oxa)
    cntr
  ];

  environment.variables.EDITOR = "vim";

  environment.etc."gitconfig".source = ./gitconfig;

  programs.less.enable = true;
  environment.variables.LESS = "--RAW-CONTROL-CHARS --quit-if-one-screen";

  programs.mtr.enable = true;
  programs.iotop.enable = true;
  programs.iftop.enable = true;

  users.defaultUserShell = pkgs.zsh;
}
