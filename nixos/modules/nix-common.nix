{ pkgs, inputs, ... }:
{
  nix = {
    gc = {
      automatic = true;
      dates = "Wed,Sat 01:00";
      options = "--delete-older-than 8d";
    };

    settings = {
      experimental-features = [
        "nix-command"
        "flakes"
        "repl-flake"
        "ca-derivations"
      ];

      allow-import-from-derivation = false;
      auto-optimise-store = true;
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
