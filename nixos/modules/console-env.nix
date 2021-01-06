{ lib, pkgs, ... }:
{
  programs.vim.defaultEditor = true;

  programs.less.enable = true;
  environment.variables.PAGER = "less --RAW-CONTROL-CHARS --quit-if-one-screen";
}
