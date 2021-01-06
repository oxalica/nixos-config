# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ lib, config, pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ./software.nix
    ./system.nix

    ../../modules/desktop-env
    ../../modules/console-env.nix
    ../../modules/nix-binary-cache-mirror.nix
    ../../modules/nix-common.nix
    ../../modules/nixpkgs-allow-unfree-list.nix
    ../../modules/steam-compat.nix
  ];

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.timeout = 1;

  boot.initrd.luks.devices."unluks" = {
    device = "/dev/disk/by-uuid/21764e86-fde3-4e51-9652-da9adbdeeb34";
    preLVM = true;
  };

  time.timeZone = "Asia/Shanghai";

  networking.hostName = "invar";

  users = {
    groups."oxa".gid = 1000;
    users."oxa" = {
      isNormalUser = true;
      uid = 1000;
      group = "oxa";
      extraGroups = [ "wheel" ];
      shell = pkgs.zsh;
    };
  };
  home-manager.users.oxa = import ../../../home/invar.nix;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "20.03"; # Did you read the comment?

}
