{
  description = "oxalica's NixOS configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    # home-manager = { url = "github:nix-community/home-manager"; inputs.nixpkgs.follows = "nixpkgs"; };
  };

  outputs = { self, nixpkgs }@inputs: let

    flake-config = { pkgs, ... }: {
      # Ensure that flake support is enabled.
      nix.package = pkgs.nixFlakes;

      # `nix.registry` is written to `/nix/nix/registry.json`.
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

    inputs' = inputs // { inherit flake-config; };

  in {
    nixosConfigurations = {
      invar = import ./nixos/hosts/invar inputs';
    };
  };
}
