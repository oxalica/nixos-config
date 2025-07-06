{
  description = "oxalica's NixOS configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixpkgs-stable.url = "github:NixOS/nixpkgs/nixos-23.11";
    nixpkgs-unmatched.url = "github:oxalica/nixpkgs/test/unmatched";

    # WAIT: https://github.com/NixOS/nixpkgs/pull/389363
    nixpkgs-logseq.url = "github:NixOS/nixpkgs/5135c59491985879812717f4c9fea69604e7f26f";

    # Placeholder.
    blank.follows = "nixpkgs";

    flake-utils.url = "github:numtide/flake-utils";
    home-manager = {
      # WAIT: https://github.com/nix-community/home-manager/pull/4976
      url = "github:nix-community/home-manager/pull/4976/head";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    rust-overlay = {
      url = "github:oxalica/rust-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nocargo = {
      url = "github:oxalica/nocargo";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-utils.follows = "flake-utils";
    };
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    lanzaboote = {
      url = "github:nix-community/lanzaboote/v0.4.2";
      inputs.pre-commit-hooks-nix.follows = "blank";
      inputs.flake-compat.follows = "blank";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.rust-overlay.follows = "rust-overlay";
    };
    orb = {
      url = "github:oxalica/orb";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    blahrs = {
      url = "github:Blah-IM/blahrs";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.rust-overlay.follows = "rust-overlay";
    };
    cargo-bloated = {
      url = "github:oxalica/cargo-bloated";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    simple-snap = {
      url = "github:oxalica/simple-snap";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    meta-sifive = {
      url = "github:sifive/meta-sifive/2021.11.00";
      flake = false;
    };

    # Optional.
    secrets.url = "/home/oxa/storage/repo/nixos-config-secrets";
  };

  outputs = { self, nixpkgs, flake-utils, ... }@inputs: let

    inherit (nixpkgs) lib;

    overlays = {
    };

    nixosModules = {
      # Ref: https://github.com/dramforever/config/blob/63be844019b7ca675ea587da3b3ff0248158d9fc/flake.nix#L24-L28
      system-label = {
        system.configurationRevision = self.rev or null;
        system.nixos.label =
          if self.sourceInfo ? lastModifiedDate && self.sourceInfo ? shortRev
          then "${lib.substring 0 8 self.sourceInfo.lastModifiedDate}.${self.sourceInfo.shortRev}"
          else lib.warn "Repo is dirty, revision will not be available in system label" "dirty";
      };

      home-manager = { config, inputs, my, ... }: {
        imports = [ inputs.home-manager.nixosModules.home-manager ];
        home-manager = {
          useGlobalPkgs = true;
          useUserPackages = true;
          verbose = true;
          extraSpecialArgs = {
            inherit inputs my;
            super = config;
          };
        };
      };

      sops = { config, ... }: {
        imports = [ inputs.sops-nix.nixosModules.sops ];
        sops.age.sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];
        sops.gnupg.sshKeyPaths = [];
        sops.defaultSopsFile = ./nixos/${config.networking.hostName}/secret.yaml;
      };
    };

    mkSystem = name: system: nixpkgs: { extraModules ? [] }: nixpkgs.lib.nixosSystem {
      inherit system;
      specialArgs = {
        inputs = inputs // { inherit nixpkgs; };
        my = import ./my // {
          pkgs = self.packages.${system};
        };
      };
      modules = with nixosModules; [
        system-label
        { networking.hostName = lib.mkDefault name; }
        { nixpkgs.overlays = builtins.attrValues overlays; }
        ./nixos/${name}/configuration.nix
      ] ++ extraModules;
    };

  in {
    inherit overlays nixosModules;

    lib = import ./lib.nix {
      inherit (nixpkgs) lib;
    };

    nixosSystems = lib.mapAttrs
      (name: conf: conf.config.system.build.toplevel)
      self.nixosConfigurations;

    nixosConfigurations = {
      invar = mkSystem "invar" "x86_64-linux" inputs.nixpkgs {
        extraModules = with nixosModules; [ home-manager sops inputs.orb.nixosModules.orb ];
      };

      blacksteel = mkSystem "blacksteel" "x86_64-linux" inputs.nixpkgs {
        extraModules = with nixosModules; [ home-manager sops ];
      };

      lithium = mkSystem "lithium" "x86_64-linux" inputs.nixpkgs {
        extraModules = with nixosModules; [ sops inputs.blahrs.nixosModules.blahd ];
      };

      copper = mkSystem "copper" "x86_64-linux" inputs.nixpkgs-stable {
        extraModules = with nixosModules; [ sops ];
      };

      unmatched = mkSystem "unmatched" "riscv64-linux" inputs.nixpkgs-unmatched { };
      unmatched-cross = mkSystem "unmatched" "x86_64-linux" inputs.nixpkgs-unmatched {
        extraModules = [
          { nixpkgs.crossSystem.config = "riscv64-unknown-linux-gnu"; }
        ];
      };

      minimal-image-stable = mkSystem "minimal-image" "x86_64-linux" inputs.nixpkgs-stable { };
      minimal-image-unstable = mkSystem "minimal-image" "x86_64-linux" inputs.nixpkgs { };
    };

    images = {
      minimal-iso-stable = self.nixosConfigurations.minimal-image-stable.config.system.build.isoImage;
      minimal-iso-unstable = self.nixosConfigurations.minimal-image-unstable.config.system.build.isoImage;
    };

    templates = {
      rust-bin = {
        description = "A simple Rust project for binaries";
        path = ./templates/rust-bin;
      };
      rust-lib = {
        description = "A simple Rust project for libraries";
        path = ./templates/rust-lib;
      };
      rust-criterion = {
        description = "Criterion benchmark templates";
        path = ./templates/rust-criterion;
      };
      ci-rust = {
        description = "A sample GitHub CI setup for Rust projects";
        path = ./templates/ci-rust;
      };
    };

  } // flake-utils.lib.eachDefaultSystem (system: rec {
    packages = import ./pkgs {
      inherit lib inputs;
      pkgs = nixpkgs.legacyPackages.${system};
    };

    checks = packages;

    devShells.default =
      with nixpkgs.legacyPackages.${system};
      mkShellNoCC {
        packages = [ nvfetcher packages.nixos-rebuild-shortcut ];
      };

    devShells.rust-nightly =
      let
        pkgs = nixpkgs.legacyPackages.${system};
        now = inputs.rust-overlay.lastModifiedDate;
        date = "${lib.substring 0 4 now}-${lib.substring 4 2 now}-01";
        toolchain = inputs.rust-overlay.packages.${system}."rust-nightly_${date}".override {
          extensions = [
            "llvm-tools"
            "miri"
            "rust-src"
          ];
        };
      in pkgs.mkShellNoCC {
        packages = [ toolchain ];
        env.CARGO_TARGET_DIR = "/tmp/cargo-nightly-target";
      };
  });
}
