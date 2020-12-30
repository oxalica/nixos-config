# Flake-related configurations are set in `flake.nix`.
{ pkgs, ... }:
{
  nix.useSandbox = true;
  nix.autoOptimiseStore = true;

  nix.trustedUsers = [ "root" "oxa" ];

  nix.gc = {
    automatic = true;
    dates = "Wed";
    options = "--delete-older-than 8d";
  };

  nix.extraOptions = ''
    download-attempts = 2
    connect-timeout = 3
    stalled-download-timeout = 10
  '';
}
