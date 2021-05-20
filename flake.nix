{
  description = "oxalica's NixOS configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgs-stable.url = "github:nixos/nixpkgs/nixos-20.09";

    flake-utils.url = "github:numtide/flake-utils";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    rust-overlay = {
      url = "github:oxalica/rust-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-utils.follows = "flake-utils";
    };

    rime-emoji = {
      url = "github:rime/rime-emoji";
      flake = false;
    };

    # Optional.
    secrets = {
      url = "/home/oxa/storage/repo/nixos-config/secrets";
      flake = false;
    };
  };

  outputs = inputs: let

    inherit (inputs.nixpkgs) lib;

    prToOverlay = pr: pathStrs: final: prev:
      with lib;
      foldl' recursiveUpdate prev (map (pathStr:
        let pathList = splitString "." pathStr; in
        setAttrByPath pathList (getAttrFromPath pathList pr.legacyPackages.${final.system})
      ) pathStrs);

    overlays = {
      rust-overlay = inputs.rust-overlay.overlay;
      xdg-path-overlay = import ./xdg-path-overlay.nix;

      tdesktop-font = final: prev: {
        tdesktop = prev.tdesktop.overrideAttrs (oldAttrs: {
          patches = (oldAttrs.patches or []) ++
            [ ./patches/tdesktop-0001-use-system-font-and-use-stylename.patch ];
        });
      };
    };

  in {
    nixosConfigurations = builtins.mapAttrs (name: path: import path {
      inherit inputs overlays;
    }) {
      blacksteel = ./nixos/hosts/blacksteel;
      invar      = ./nixos/hosts/invar;
      silver     = ./nixos/hosts/silver;

      iso        = ./nixos/hosts/iso;
    };
  };
}
