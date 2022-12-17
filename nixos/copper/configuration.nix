{ lib, config, pkgs, inputs, ... }:
{
  imports = [
    ../modules/vultr-common.nix
    ../modules/console-env.nix
    ../modules/nix-common.nix

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

  system.stateVersion = "22.11";
}
