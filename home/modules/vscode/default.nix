{ lib, pkgs, ... }:

{
  programs.vscode = {
    enable = true;
    package = pkgs.vscodium;
    userSettings = import ./settings.nix { inherit pkgs; };
    extensions = import ./extensions.nix {
      inherit pkgs;
      extensionFromMarket = pkgs.vscode-utils.extensionFromVscodeMarketplace;
    };
  };
}
