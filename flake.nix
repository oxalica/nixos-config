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

    pr-isgx.url = "github:nixos/nixpkgs/pull/109013/head";
    pr-electron-cash.url = "github:nixos/nixpkgs/pull/118723/head";
    # Waiting for https://github.com/NixOS/nixpkgs/pull/118365
    pr-steam.url = "github:nixos/nixpkgs/f5e8bdd07d1afaabf6b37afc5497b1e498b8046f";

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
      electron-cash = prToOverlay inputs.pr-electron-cash [ "electron-cash" ];
      steam = final: prev: {
        inherit (import inputs.pr-steam {
          inherit (final) system;
          config.allowUnfree = true;
        }) steam;
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
