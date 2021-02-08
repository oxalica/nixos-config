{
  description = "oxalica's NixOS configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    home-manager = { url = "github:nix-community/home-manager"; inputs.nixpkgs.follows = "nixpkgs"; };
    rust-overlay = {
      url = "github:oxalica/rust-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-utils.follows = "flake-utils";
    };

    # https://github.com/NixOS/nixpkgs/pull/101179
    pr-vscode-lldb.url = "github:nixos/nixpkgs/c5a82fbadbc71def3a04d95ba4d400d397bb0723";
    # https://github.com/NixOS/nixpkgs/pull/109013
    pr-isgx.url = "github:nixos/nixpkgs/5d5ed1a59cc4c7f4fd63cee75aa31dd92b9c7242";

    # Optional.
    secrets = { url = "git+ssh://git@github.com/oxalica/nixos-config-secrets.git"; flake = false; };
  };

  outputs = { self, nixpkgs, ... }@inputs: let

    prToOverlay = pr: pathStrs: final: prev:
      with nixpkgs.lib;
      foldl' recursiveUpdate prev (map (pathStr:
        let pathList = splitString "." pathStr; in
        setAttrByPath pathList (getAttrFromPath pathList pr.legacyPackages.${final.system})
      ) pathStrs);

    overlays = [
      inputs.rust-overlay.overlay
      (prToOverlay inputs.pr-vscode-lldb ["vscode-extensions.vadimcn.vscode-lldb"])
      (prToOverlay inputs.pr-isgx ["linuxPackages.isgx"])
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
      blacksteel = "x86_64-linux";
      invar = "x86_64-linux";
      silver = "x86_64-linux";

      iso = "x86_64-linux";
    };
  };
}
