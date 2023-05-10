{ inputs, ... }:
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

      # FIXME: https://github.com/NixOS/nix/commit/a642b1030188f7538ef6243cd7fd1404419a6933
      flake-registry = builtins.toFile "empty-registry.json"
        (builtins.toJSON { flakes = []; version = 2; });

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
