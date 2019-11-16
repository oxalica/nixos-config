{ lib, pkgs, ... }:

lib.recursiveUpdate {
  imports = [
    ./zsh.nix
    ./vim.nix
    ./git.nix
    ./users.nix
  ];

  environment.systemPackages = with pkgs; [
    tealdeer wget curl pv htop tree loop bc file lz4
    screen
    git python3
  ];

} (lib.mapAttrsRecursive (k: lib.mkOverride 500) {

  programs.less.enable = true;

  programs.mtr.enable = true;
  programs.iotop.enable = true;
  programs.iftop.enable = true;
})
