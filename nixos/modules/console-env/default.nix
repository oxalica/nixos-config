{ lib, config, pkgs, ... }:
{
  imports = [
    ./vim.nix
    ./zsh.nix
  ];

  programs.less.enable = true;
  environment.variables.PAGER = "less --RAW-CONTROL-CHARS --quit-if-one-screen";

  environment.etc."gitconfig".source = ./gitconfig;

  environment.systemPackages = with pkgs; [
    git
  ];
}
