{ lib, pkgs, ... }:

lib.mapAttrsRecursive (k: lib.mkOverride 500) {

  networking.firewall.logRefusedConnections = false;

  services.ntp.enable = true;

  services.earlyoom.enable = true;

  nix.useSandbox = true;

  nix.trustedUsers = [ "root" "oxa" ];

  nix.gc = {
    automatic = true;
    dates = "thursday";
    options = "--delete-older-than 8d";
  };

  nix.optimise = {
    automatic = true;
    dates = [ "sunday" ];
  };

  services.fstrim = {
    enable = true;
    interval = "tuesday";
  };
}
