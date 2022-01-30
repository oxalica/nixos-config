{ pkgs, inputs, ... }:
{
  nix = {
    # Ensure that flake support is enabled.
    package = pkgs.nixFlakes;

    gc = {
      automatic = true;
      dates = "Wed";
      options = "--delete-older-than 8d";
    };

    settings = {
      trusted-users = [ "root" "@wheel" ];
      auto-optimise-store = true;
    };

    extraOptions = ''
      experimental-features = nix-command flakes
      flake-registry = /etc/nix/registry.json

      download-attempts = 5
      connect-timeout = 15
      stalled-download-timeout = 10

      keep-outputs = true # Keep build-dependencies.

      builders-use-substitutes = true

      allow-import-from-derivation = false
    '';

    registry = {
      nixpkgs = {
        from = { id = "nixpkgs"; type = "indirect"; };
        flake = inputs.nixpkgs;
      };
    };

    nixPath = [
      "nixpkgs=${inputs.nixpkgs}"
    ];
  };
}
