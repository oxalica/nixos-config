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

    nixpkgs-nixos-tag.url = "github:nixos/nixpkgs/pull/130388/head";

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

      old-firmware = final: prev: {
        inherit (inputs.nixpkgs-old-firmware.legacyPackages.${final.system}) firmwareLinuxNonfree;
      };
    };

    # Temporary fix for https://github.com/NixOS/nixpkgs/issues/128893.
    config-alsa-1-2-5-1 = { lib, pkgs, ... }: {
      system.replaceRuntimeDependencies = lib.singleton {
        original = pkgs.alsa-lib;
        replacement = pkgs.alsa-lib.overrideAttrs (drv: {
          # NOTES:
          #
          # Since the store paths are replaced in the system closure, we can't use
          # "1.2.5.1" here because it would result in a different length.
          #
          # Additionally, the assertion here is to make sure that once version
          # 1.2.5.1 hits the system we get an error and can remove this altogether.
          version = assert pkgs.alsa-lib.version == "1.2.5"; "1.2.X";
          src = pkgs.fetchurl {
            url = "mirror://alsa/lib/${drv.pname}-1.2.5.1.tar.bz2";
            hash = "sha256-YoQh2VDOyvI03j+JnVIMCmkjMTyWStdR/6wIHfMxQ44=";
          };
        });
      };
    };

    config-nixos-tag = { config, lib, pkgs, ... }: let
      setup-etc-pl = inputs.nixpkgs-nixos-tag + "/nixos/modules/system/etc/setup-etc.pl";
      etc = config.system.build.etc;
    in {
      system.activationScripts.etc = lib.stringAfter [ "users" "groups" ]
        ''
          # Set up the statically computed bits of /etc.
          echo "setting up /etc..."
          ${pkgs.perl.withPackages (p: [ p.FileSlurp ])}/bin/perl ${setup-etc-pl} ${etc}/etc
        '';
    };

    # Ref: https://github.com/dramforever/config/blob/63be844019b7ca675ea587da3b3ff0248158d9fc/flake.nix#L24-L28
    system-label = let inherit (inputs) self; in {
      system.configurationRevision = self.rev or null;
      system.nixos.label =
        if self.sourceInfo ? lastModifiedDate && self.sourceInfo ? shortRev
        then "${lib.substring 0 8 self.sourceInfo.lastModifiedDate}.${self.sourceInfo.shortRev}"
        else lib.warn "Repo is dirty, revision will not be available in system label" "dirty";
    };

    mkSystem = system: overlays: modules: inputs.nixpkgs.lib.nixosSystem {
      inherit system;
      specialArgs.inputs = inputs;
      modules = [
        system-label
        inputs.home-manager.nixosModules.home-manager
        { nixpkgs.overlays = overlays; }
        ({ lib, ... }: {
          options.home-manager.users = with lib.types; lib.mkOption {
            type = attrsOf (submoduleWith {
              modules = [ ];
              specialArgs.inputs = inputs;
            });
          };
        })
      ] ++ modules;
    };

  in {
    nixosConfigurations = builtins.mapAttrs (name: path: import path {
      inherit inputs overlays;
    }) {
      silver     = ./nixos/hosts/silver;

      iso        = ./nixos/hosts/iso;

    } // {
      invar = mkSystem "x86_64-linux"
        (with overlays; [ rust-overlay xdgify-overlay old-firmware ])
        [ ./nixos/hosts/invar/configuration.nix config-alsa-1-2-5-1 config-nixos-tag ];

      blacksteel = mkSystem "x86_64-linux"
        (with overlays; [ rust-overlay ])
        [ ./nixos/hosts/blacksteel/configuration.nix ];
    };
  };
}
