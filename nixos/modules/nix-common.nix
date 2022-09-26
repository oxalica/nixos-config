{ pkgs, inputs, ... }:
{
  nix = {
    gc = {
      automatic = true;
      dates = "Sat 03:00";
      options = "--delete-older-than 8d";
    };

    settings = {
      allow-import-from-derivation = false;
      auto-optimise-store = true;
      experimental-features = [ "nix-command" "flakes" ];
      flake-registry = "/etc/nix/registry.json"; # Don't fetch from GitHub.
      trusted-users = [ "root" "@wheel" ];

      connect-timeout = 10;
      download-attempts = 3;
      stalled-download-timeout = 10;
    };

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
