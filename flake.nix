{
  description = "oxalica's NixOS configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgs-stable.url = "github:nixos/nixpkgs/nixos-20.09";

    # `amdgpu` causes GPU reset when using firefox hardware decoding, in current unstable.
    # Checkout old firmware for test.
    # 11 May 00:20 system-128-link -> /nix/store/r5275bdswf52h02zshqx3v448ghp959x-nixos-system-invar-21.05.20210506.6358647/
    # 20 May 18:50 system-129-link -> /nix/store/7x4hk9mwzi18nx4x0zx61x4rysmkdb8c-nixos-system-invar-21.05.20210516.7a1fbc3/ <- seems the first bad
    # 24 May 15:26 system-130-link -> /nix/store/b44fr7qy02yp0c65k30ra7lbxcnh4h2r-nixos-system-invar-21.05.20210523.900115a/
    # 25 May 01:14 system-131-link -> /nix/store/zyb0s5kjpykfa7gnkwq922svkw0m4mdl-nixos-system-invar-21.05.20210523.900115a/
    # 25 May 20:31 system-132-link -> /nix/store/jypydm0v61y6jl8bv20ciix0rkdf5gkj-nixos-system-invar-21.05.20210523.900115a/
    nixpkgs-old-firmware.url = "github:nixos/nixpkgs/63586475587d7e0e078291ad4b49b6f6a6885100";

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
    xdgify-overlay = {
      url = "github:oxalica/xdgify-overlay";
      # url = "/home/oxa/storage/repo/xdgify-overlay";
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
      xdgify-overlay = inputs.xdgify-overlay.overlay;

      tdesktop-font = final: prev: {
        tdesktop = prev.tdesktop.overrideAttrs (oldAttrs: {
          patches = (oldAttrs.patches or []) ++
            [ ./patches/tdesktop-0001-use-system-font-and-use-stylename.patch ];
        });
      };

      old-firmware = final: prev: {
        inherit (inputs.nixpkgs-old-firmware.legacyPackages.${final.system}) firmwareLinuxNonfree;
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
