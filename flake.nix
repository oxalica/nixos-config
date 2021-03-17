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

    # https://github.com/NixOS/nixpkgs/pull/109013
    pr-isgx.url = "github:nixos/nixpkgs/5d5ed1a59cc4c7f4fd63cee75aa31dd92b9c7242";
    # https://github.com/NixOS/nixpkgs/pull/114016
    pr-partition-manager.url = "github:nixos/nixpkgs/24ea8cfe75a9671192701b55ab93ef2d6417e780";

    # Optional.
    secrets = {
      url = "git+ssh://git@github.com/oxalica/nixos-config-secrets.git";
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
      isgx = prToOverlay inputs.pr-isgx [ "linuxPackages.isgx" ];
      partition-manager = prToOverlay inputs.pr-partition-manager [ "libsForQt5.kpmcore" "partition-manager" ];
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
