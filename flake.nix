{
  description = "oxalica's NixOS configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager = { url = "github:nix-community/home-manager"; inputs.nixpkgs.follows = "nixpkgs"; };

    # mozilla = { url = "github:mozilla/nixpkgs-mozilla"; flake = false; }; # It's not pure!
  };

  outputs = { self, nixpkgs, ... }@inputs: let

    overlays = [
      # (import inputs.mozilla)
    ];

    flake-config = { pkgs, ... }: {
      # Ensure that flake support is enabled.
      nix.package = pkgs.nixFlakes;

      # `nix.registry` is written to `/etc/nix/registry.json`.
      nix.extraOptions = ''
        experimental-features = nix-command flakes
        flake-registry = /etc/nix/registry.json
      '';

      nix.registry = {
        nixpkgs = {
          from = { id = "nixpkgs"; type = "indirect"; };
          flake = nixpkgs;
        };
      };
      # From: https://github.com/cole-h/nixos-config/blob/f22dfeeaadfb16d79b04d2ee8ee8d02b8ef00faa/flake.nix#L116
      nix.nixPath = [
        "nixpkgs=${nixpkgs}"
        # "nixos-config=${self}/compat/nixos"
      ];
    };

    mkSystem = system: modules: nixpkgs.lib.nixosSystem {
      inherit system;
      modules = modules ++ [
        flake-config
        { nixpkgs.overlays = overlays; }
      ];
    };

    mkHomeSystem = system: modules: mkSystem system (modules ++ [
      inputs.home-manager.nixosModules.home-manager
      {
        home-manager.useGlobalPkgs = true;
        home-manager.useUserPackages = true;
      }
    ]);

  in {
    nixosConfigurations = {
      invar = mkHomeSystem "x86_64-linux" [ ./nixos/hosts/invar/configuration.nix ];
    };
  };
}
