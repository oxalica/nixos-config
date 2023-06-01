# NB. systemd-initrd doesn't work for ISO yet.
{ config, pkgs, modulesPath, ... }:
{
  imports = [
    (modulesPath + "/installer/cd-dvd/installation-cd-minimal.nix")
    ../modules/console-env.nix
    ../modules/nix-binary-cache-mirror.nix
  ];

  isoImage = {
    isoBaseName = "nixoxa";
    volumeID = "NIXOXA";
    # Worse compression but way faster.
    squashfsCompression = "zstd -Xcompression-level 6";
  };

  networking.hostName = "nixoxa";

  nix = {
    settings = {
      experimental-features = [
        "nix-command"
        "flakes"
        "repl-flake"
      ];

      flake-registry = "";
    };

    nixPath = [ "nixpkgs=${config.nix.registry.nixpkgs.to.path}" ];
  };

  environment.systemPackages = with pkgs; [
    neofetch
    sbctl # Secure boot.
  ];

  system.stateVersion = "23.05";
}
