{ lib, config, pkgs, modulesPath, inputs, ... }:
{
  imports = [
    (modulesPath + "/installer/cd-dvd/installation-cd-minimal.nix")
    ../modules/nix-binary-cache-mirror.nix
    ../modules/console-env.nix
  ];

  isoImage = {
    isoBaseName = "nixoxa";
    volumeID = "NIXOXA";
  };

  # Nix flake.
  nix = {
    package = pkgs.nixFlakes;
    useSandbox = true;
    /*
    FIXME: Will introduce 2 nixpkgs in store.
    registry.nixpkgs = {
      from = { id = "nixpkgs"; type = "indirect"; };
      flake = inputs.nixpkgs;
    };
    nixPath = [ "nixpkgs=${inputs.nixpkgs}" ];
    */
  };

  environment.systemPackages = with pkgs; [
    neofetch zstd
    gnupg age sops ssh-to-age
  ];
}
