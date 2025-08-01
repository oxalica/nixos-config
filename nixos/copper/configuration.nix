{
  lib,
  pkgs,
  inputs,
  ...
}:
{
  imports = [
    ../modules/console-env.nix
    ../modules/nix-common.nix
    ../modules/vultr-common.nix

    inputs.secrets.nixosModules.copper
  ];

  fileSystems."/".fsType = lib.mkForce "btrfs";

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
