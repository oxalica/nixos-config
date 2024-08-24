{ lib, pkgs, inputs, ... }:
{
  # Ensure this is >= 2.22.1 with the following fix included, or it failes to eval.
  # https://github.com/NixOS/nix/pull/10456
  nix.package = lib.mkDefault pkgs.nixVersions.latest;

  nix.channel.enable = false;

  nix.gc = {
    automatic = true;
    dates = "Wed,Sat 01:00";
    options = "--delete-older-than 8d";
    persistent = false;
  };
  systemd.services.nix-gc.serviceConfig = {
    Nice = 19;
    IOSchedulingClass = "idle";
    MemorySwapMax = 0;
  };

  nix.settings = {
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

  nix.registry = {
    nixpkgs = {
      from = { id = "nixpkgs"; type = "indirect"; };
      flake = inputs.nixpkgs;
    };
  };

  nix.nixPath = [
    "nixpkgs=${inputs.nixpkgs}"
  ];
}
