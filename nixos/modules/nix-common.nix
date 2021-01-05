# Flake-related configurations are set in `flake.nix`.
{ pkgs, ... }:
{
  nix.useSandbox = true;

  nix.trustedUsers = [ "root" "oxa" ];

  nix.gc = {
    automatic = true;
    dates = "Wed";
    options = "--delete-older-than 8d";
  };

  nix.autoOptimiseStore = true;
  # nix.optimise = {
  #   automatic = true;
  #   dates = [ "Thu" ];
  # };

  nix.extraOptions = ''
    download-attempts = 5
    connect-timeout = 15
    stalled-download-timeout = 10
  '';
}
