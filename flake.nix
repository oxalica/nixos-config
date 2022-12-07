{
  description = "oxalica's NixOS configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixpkgs-unmatched.url = "github:oxalica/nixpkgs/test/unmatched";
    # FIXME: tdesktop 4.4.0 https://github.com/NixOS/nixpkgs/pull/204906
    nixpkgs-tdesktop.url = "github:NixOS/nixpkgs/pull/204906/head";

    flake-utils.url = "github:numtide/flake-utils";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.utils.follows = "flake-utils";
    };
    rust-overlay = {
      url = "github:oxalica/rust-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-utils.follows = "flake-utils";
    };
    nocargo = {
      url = "github:oxalica/nocargo";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-utils.follows = "flake-utils";
    };
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
      # Only for checks.
      inputs.nixpkgs-22_05.follows = "nixpkgs";
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

    overlays = [
      (final: prev: {
        tdesktop = inputs.nixpkgs-tdesktop.legacyPackages.${final.system}.tdesktop;
      })
    ];

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

      # FIXME: This requires IFD and impure.
      fix-qtwayland-crash = { pkgs, ... }: {
        system.replaceRuntimeDependencies = with pkgs; [
          {
            original = qt5.qtwayland;
            replacement = callPackage ./pkgs/qt5wayland.nix { };
          }
          {
            original = qt6.qtwayland;
            replacement = callPackage ./pkgs/qt6wayland { };
          }
        ];
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
        { networking.hostName = name; }
        { nixpkgs.overlays = overlays; }
        ./nixos/${name}/configuration.nix
      ] ++ extraModules;
    };

  in {
    inherit nixosModules;

    nixosConfigurations = {
      invar = mkSystem "invar" "x86_64-linux" inputs.nixpkgs {
        extraModules = with nixosModules; [ home-manager sops fix-qtwayland-crash ];
      };

      blacksteel = mkSystem "blacksteel" "x86_64-linux" inputs.nixpkgs {
        extraModules = with nixosModules; [ home-manager sops fix-qtwayland-crash ];
      };

      silver = mkSystem "silver" "x86_64-linux" inputs.nixpkgs {
        extraModules = with nixosModules; [ sops ];
      };

      lithium = mkSystem "lithium" "x86_64-linux" inputs.nixpkgs {
        extraModules = with nixosModules; [ sops ];
      };

      copper = mkSystem "copper" "x86_64-linux" inputs.nixpkgs {
        extraModules = with nixosModules; [ sops ];
      };

      unmatched = mkSystem "unmatched" "riscv64-linux" inputs.nixpkgs-unmatched { };
      unmatched-cross = mkSystem "unmatched" "x86_64-linux" inputs.nixpkgs-unmatched {
        extraModules = [
          { nixpkgs.crossSystem.config = "riscv64-unknown-linux-gnu"; }
        ];
      };

      iso = mkSystem "iso" "x86_64-linux" inputs.nixpkgs { };
      iso-graphical = mkSystem "iso-graphical" "x86_64-linux" inputs.nixpkgs { };
    };

  } // flake-utils.lib.eachDefaultSystem (system: rec {
    packages = import ./pkgs {
      inherit lib;
      pkgs = nixpkgs.legacyPackages.${system};
    };

    checks = packages;

    devShells.default =
      with nixpkgs.legacyPackages.${system};
      mkShell {
        packages = [ nvfetcher ];
      };
  });
}
