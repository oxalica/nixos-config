{ inputs, ... }:
{
  imports = [
    ../modules/vultr-common.nix
    ../modules/console-env.nix
    ../modules/nix-common.nix

    inputs.secrets.nixosModules.lithium
  ];

  networking.hostName = "lithium";

  system.stateVersion = "21.05";
}
