{ lib, pkgs, inputs, ... }:
{
  nix = {
    # Ensure this is >= 2.22.1 with the following fix included, or it failes to eval.
    # https://github.com/NixOS/nix/pull/10456
    package = lib.mkDefault pkgs.nixVersions.latest;

    channel.enable = false;

    gc = {
      automatic = true;
      dates = "Wed,Sat 01:00";
      options = "--delete-older-than 8d";
      persistent = false;
    };

    settings = {
      experimental-features = [
        "nix-command"
        "flakes"
        "ca-derivations"
      ];

      flake-registry = "";

      allow-import-from-derivation = false;
      auto-optimise-store = true;
      trusted-users = [ "root" "@wheel" ];

      connect-timeout = 10;
      download-attempts = 3;
      stalled-download-timeout = 10;

      # Workaround: https://github.com/NixOS/nixpkgs/pull/273170
      nix-path = "nixpkgs=${inputs.nixpkgs}";
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
