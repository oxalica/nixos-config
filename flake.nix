{
  description = "oxalica's NixOS configuration";

  inputs = {
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixpkgs-stable.url = "github:NixOS/nixpkgs/nixos-22.05";
    nixpkgs-unmatched.url = "github:oxalica/nixpkgs/test/unmatched";

    # FIXME: Wait for https://github.com/swaywm/swaylock/issues/204
    nixpkgs-sway-lock-fix.url = "github:oxalica/nixpkgs/bump/sway-wlroots";

    flake-utils.url = "github:numtide/flake-utils";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
      inputs.utils.follows = "flake-utils";
    };
    rust-overlay = {
      url = "github:oxalica/rust-overlay";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
      inputs.flake-utils.follows = "flake-utils";
    };
    nocargo = {
      url = "github:oxalica/nocargo";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
      inputs.flake-utils.follows = "flake-utils";
    };
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
      # Only for checks.
      inputs.nixpkgs-22_05.follows = "nixpkgs-unstable";
    };

    meta-sifive = {
      url = "github:sifive/meta-sifive/2021.11.00";
      flake = false;
    };
    rime-latex = {
      url = "github:shenlebantongying/rime_latex";
      flake = false;
    };
    tree-sitter-nix = {
      url = "github:oxalica/tree-sitter-nix";
      # url = "/home/oxa/repo/fork/tree-sitter-nix";
      flake = false;
    };
    tree-sitter-bash = {
      # With support for zsh.
      url = "github:tree-sitter/tree-sitter-bash";
      flake = false;
    };

    # Optional.
    secrets.url = "/home/oxa/storage/repo/nixos-config-secrets";
  };

  outputs = { nixpkgs-unstable, nixpkgs-stable, flake-utils, ... }@inputs: let

    inherit (nixpkgs-unstable) lib;

    prToOverlay = pr: pathStrs: final: prev:
      with lib;
      foldl' recursiveUpdate prev (map (pathStr:
        let pathList = splitString "." pathStr; in
        setAttrByPath pathList (getAttrFromPath pathList pr.legacyPackages.${final.system})
      ) pathStrs);

    overlays = {
      mypkgs = final: prev: import ./pkgs { inherit (final) callPackage; };
      rust-overlay = inputs.rust-overlay.overlays.default;

      prefer-remote-fetch = final: prev: prev.prefer-remote-fetch final prev;

      sway-lock-fix = final: prev: {
        sway-unwrapped = final.callPackage (inputs.nixpkgs-sway-lock-fix + "/pkgs/applications/window-managers/sway/default.nix") {
          wlroots = final.callPackage (inputs.nixpkgs-sway-lock-fix + "/pkgs/development/libraries/wlroots/0.16.nix") { };
        };
      };
    };

    nixosModules = {
      # Ref: https://github.com/dramforever/config/blob/63be844019b7ca675ea587da3b3ff0248158d9fc/flake.nix#L24-L28
      system-label = let inherit (inputs) self; in {
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

      # FIXME: Wait for https://github.com/NixOS/nixpkgs/pull/178529
      initrd-systemd-fix = { config, ... }: {
        boot.initrd.systemd.storePaths =
          lib.optional (lib.hasPrefix builtins.storeDir config.console.font) "${config.console.font}" ++
          lib.optional (lib.hasPrefix builtins.storeDir config.console.keyMap) "${config.console.keyMap}";
      };
    };

    mkSystem = name: system: nixpkgs: { extraOverlays ? [], extraModules ? [] }: nixpkgs.lib.nixosSystem {
      inherit system;
      specialArgs.inputs = inputs // { inherit nixpkgs; };
      specialArgs.my = import ./my;
      modules = with nixosModules; [
        system-label
        {
          networking.hostName = name;
          nixpkgs.overlays = with overlays; [
            mypkgs
            rust-overlay
          ] ++ extraOverlays;
        }
        ./nixos/${name}/configuration.nix
      ] ++ extraModules;
    };

  in {
    inherit overlays nixosModules;

    nixosConfigurations = {
      invar = mkSystem "invar" "x86_64-linux" inputs.nixpkgs-unstable {
        extraOverlays = with overlays; [ sway-lock-fix ];
        extraModules = with nixosModules; [ home-manager sops initrd-systemd-fix ];
      };

      blacksteel = mkSystem "blacksteel" "x86_64-linux" inputs.nixpkgs-unstable {
        extraOverlays = with overlays; [ ];
        extraModules = with nixosModules; [ home-manager sops ];
      };

      silver = mkSystem "silver" "x86_64-linux" inputs.nixpkgs-stable {
        extraModules = with nixosModules; [ sops ];
      };

      lithium = mkSystem "lithium" "x86_64-linux" inputs.nixpkgs-stable {
        extraModules = with nixosModules; [ sops ];
      };

      copper = mkSystem "copper" "x86_64-linux" inputs.nixpkgs-stable {
        extraModules = with nixosModules; [ sops ];
      };

      unmatched = mkSystem "unmatched" "riscv64-linux" inputs.nixpkgs-unmatched { };
      unmatched-cross = mkSystem "unmatched" "x86_64-linux" inputs.nixpkgs-unmatched {
        extraModules = with nixosModules; [
          { nixpkgs.crossSystem.config = "riscv64-unknown-linux-gnu"; }
        ];
      };

      iso = mkSystem "iso" "x86_64-linux" inputs.nixpkgs-stable { };
      iso-graphical = mkSystem "iso-graphical" "x86_64-linux" inputs.nixpkgs-unstable { };
    };
  };
}
