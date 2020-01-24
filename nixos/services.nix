{ lib, pkgs, ... }:

lib.mapAttrsRecursive (k: lib.mkOverride 500) {

  networking.firewall.logRefusedConnections = false;

  services.ntp.enable = true;

  services.earlyoom.enable = true;

  nix.useSandbox = true;

  nix.trustedUsers = [ "root" "oxa" ];

  nix.gc = {
    automatic = true;
    dates = "Mon,Fri";
    options = "--delete-older-than 5d";
  };

  nix.optimise = {
    automatic = true;
    dates = [ "Tue,Sat" ];
  };

  services.fstrim = {
    enable = true;
    interval = "Wed";
  };
}
