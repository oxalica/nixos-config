# Flake-related configurations are set in `flake.nix`.
{ pkgs, inputs, ... }:
{
  nix = {
    # Ensure that flake support is enabled.
    package = pkgs.nixFlakes;

    useSandbox = true;

    trustedUsers = [ "root" "oxa" ];

    gc = {
      automatic = true;
      dates = "Wed";
      options = "--delete-older-than 8d";
    };

    autoOptimiseStore = true;
    # optimise = {
    #   automatic = true;
    #   dates = [ "Thu" ];
    # };

    extraOptions = ''
      experimental-features = nix-command flakes
      flake-registry = /etc/nix/registry.json

      download-attempts = 5
      connect-timeout = 15
      stalled-download-timeout = 10

      keep-outputs = true # Keep build-dependencies.
    '';

    registry = {
      nixpkgs = {
        from = { id = "nixpkgs"; type = "indirect"; };
        flake = inputs.nixpkgs;
      };
    };

    # From: https://github.com/cole-h/nixos-config/blob/f22dfeeaadfb16d79b04d2ee8ee8d02b8ef00faa/flake.nix#L116
    nixPath = [
      "nixpkgs=${inputs.nixpkgs}"
    ];
  };
}
