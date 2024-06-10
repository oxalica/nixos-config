# NB. systemd-initrd doesn't work for ISO yet.
{ lib, config, pkgs, modulesPath, ... }:
{
  imports = [
    (modulesPath + "/installer/cd-dvd/installation-cd-minimal-new-kernel-no-zfs.nix")
    ../modules/console-env.nix
    ../modules/nix-binary-cache-mirror.nix
  ];

  isoImage = {
    isoBaseName = "nixoxa";
    volumeID = "NIXOXA";
    # Worse compression but way faster.
    squashfsCompression = "zstd -Xcompression-level 6";
  };

  # Workaround: https://github.com/NixOS/nixpkgs/issues/254807
  boot.swraid.enable = lib.mkForce false;

  networking.hostName = "nixoxa";

  nix = {
    settings = {
      experimental-features = [
        "nix-command"
        "flakes"
      ];

      flake-registry = "";
    };

    nixPath = [ "nixpkgs=${config.nix.registry.nixpkgs.to.path}" ];
  };

  environment.systemPackages = with pkgs; [
    neofetch
    sbctl # Secure boot.
  ];

  system.stateVersion = "24.05";
}
