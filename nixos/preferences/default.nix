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
    git python3
  ];

} (lib.mapAttrsRecursive (k: lib.mkOverride 500) {

  environment.variables.PAGER = "less";
  programs.less = {
    enable = true;
    envVariables.LESS = "-R --quit-if-one-screen";
  };

  programs.mtr.enable = true;
  programs.iotop.enable = true;
  programs.iftop.enable = true;
})
