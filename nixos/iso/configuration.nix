{ lib, pkgs, modulesPath, ... }:
{
  imports = [
    (modulesPath + "/installer/cd-dvd/installation-cd-minimal.nix")
    ../modules/nix-binary-cache-mirror.nix
    ../modules/console-env.nix
  ];

  isoImage = {
    isoBaseName = "nixoxa";
    volumeID = "NIXOXA";
    # Worse compression but way faster.
    squashfsCompression = "zstd -Xcompression-level 6";
  };

  nix = {
    extraOptions = ''
      experimental-features = nix-command flakes
      flake-registry = /etc/nix/registry.json
    '';

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
    neofetch
  ];

  system.stateVersion = "22.05";
}
