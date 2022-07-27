{ lib, pkgs, modulesPath, ... }:
{
  imports = [
    (modulesPath + "/installer/cd-dvd/installation-cd-graphical-plasma5.nix")
    ../modules/console-env.nix
    ../modules/kde-desktop
    ../modules/l10n.nix
    ../modules/nix-binary-cache-mirror.nix
    ../modules/sway-desktop.nix
  ];

  # Use rc kernels for recent hardwares.
  boot.kernelPackages = pkgs.linuxPackages_testing;
  # No zfs for rc kernels.
  boot.supportedFilesystems = lib.mkForce [ "btrfs" "reiserfs" "vfat" "f2fs" "xfs" "ntfs" "cifs" ];

  isoImage = {
    isoBaseName = "nixoxag";
    volumeID = "NIXOXAG";
    # Worse compression but way faster.
    squashfsCompression = "zstd -Xcompression-level 6";
  };

  nix = {
    extraOptions = ''
      experimental-features = nix-command flakes
      flake-registry = /etc/nix/registry.json
    '';
  };

  hardware.bluetooth.enable = true;

  programs.sway.enable = true;

  environment.systemPackages = with pkgs; [
    neofetch
  ];

  system.stateVersion = "22.05";
}
