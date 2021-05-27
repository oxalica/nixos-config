{ lib, pkgs, ... }:
{
  programs.vim.defaultEditor = true;

  programs.less.enable = true;
  programs.less.envVariables.LESS = "--RAW-CONTROL-CHARS --quit-if-one-screen --mouse";

  programs.iotop.enable = true;
  programs.iftop.enable = true;

  environment.systemPackages = with pkgs; [
    htop
    screen
  ];
}
