{ lib, pkgs, ... }:
{
  programs.vim.defaultEditor = true;

  programs.less.enable = true;
  environment.variables.PAGER = "less --RAW-CONTROL-CHARS --quit-if-one-screen";

  programs.iotop.enable = true;
  programs.iftop.enable = true;

  environment.systemPackages = with pkgs; [
    htop
    screen
  ];
}
