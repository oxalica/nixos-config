{ pkgs, ... }:
{
  imports = [
    ../modules/console-env.nix
    ../modules/nix-common.nix
    ../modules/vultr-common.nix
  ];

  documentation.enable = false;

  fileSystems."/" = lib.mkForce {
    device = "/dev/disk/by-label/nixos";
    fsType = "btrfs";
    options = [ "noatime" "space_cache=v2" "compress=zstd" ];
  };

  swapDevices = [
    {
      device = "/var/swapfile";
      size = 1024;
    }
  ];

  environment.systemPackages = with pkgs; [
    git
  ];

  system.stateVersion = "24.05";
}
