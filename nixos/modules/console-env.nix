{ lib, pkgs, ... }:
{
  programs.vim.defaultEditor = true;

  programs.less.enable = true;
  programs.less.envVariables.LESS = lib.concatStringsSep " " [
    "--RAW-CONTROL-CHARS"
    "--quit-if-one-screen"
    "--mouse"
    "--wheel-lines=5"
    "--no-init" # Don't clear on exit.
  ];

  programs.iotop.enable = true;
  programs.iftop.enable = true;

  environment.systemPackages = with pkgs; [ htop ];
}
