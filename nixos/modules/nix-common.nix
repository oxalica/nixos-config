{ pkgs, inputs, ... }:
{
  nix = {
    # !! Warning: 2.19 currently fails to build this config !!
    # See: https://github.com/nix-community/home-manager/issues/4692
    package = assert builtins.compareVersions pkgs.nix.version "2.19" < 0; pkgs.nix;

    channel.enable = false;

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

      flake-registry = "";

      allow-import-from-derivation = false;
      auto-optimise-store = true;
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
