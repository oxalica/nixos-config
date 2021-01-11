{
  description = "oxalica's NixOS configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager = { url = "github:nix-community/home-manager"; inputs.nixpkgs.follows = "nixpkgs"; };
    rust-overlay = { url = "github:oxalica/rust-overlay"; inputs.nixpkgs.follows = "nixpkgs"; };

    # Optional.
    secrets = { url = "git+ssh://git@github.com/oxalica/nixos-config-secrets.git"; flake = false; };
  };

  outputs = { self, nixpkgs, ... }@inputs: let

    overlays = [
      inputs.rust-overlay.overlay
    ];

    mkSystem = configuration: system: nixpkgs.lib.nixosSystem {
      inherit system;
      modules = [
        inputs.home-manager.nixosModules.home-manager
        { nixpkgs.overlays = overlays; }
        configuration
      ];
      # From: https://github.com/cole-h/nixos-config/blob/92749c8d5fa807692298c20c3819df07774c235c/flake.nix#L163
      specialArgs = {
        inherit inputs;
      };
    };

  in {
    nixosConfigurations = nixpkgs.lib.mapAttrs (
      name: mkSystem (./nixos/hosts + "/${name}/configuration.nix")
    ) {
      invar = "x86_64-linux";
    };
  };
}
