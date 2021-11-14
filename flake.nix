{
  description = "oxalica's NixOS configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgs-stable.url = "github:nixos/nixpkgs/nixos-21.05";

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

    registry-crates-io = {
      url = "github:rust-lang/crates.io-index";
      flake = false;
    };

    rime-emoji = {
      url = "github:rime/rime-emoji";
      flake = false;
    };

    neovim = {
      url = "github:neovim/neovim";
      flake = false;
    };
    nvim-treesitter = {
      url = "github:nvim-treesitter/nvim-treesitter";
      flake = false;
    };
    tree-sitter-nix = {
      url = "github:oxalica/tree-sitter-nix";
      # url = "/home/oxa/repo/fork/tree-sitter-nix";
      flake = false;
    };
    tree-sitter-bash = {
      url = "github:tree-sitter/tree-sitter-bash/pull/109/head";
      flake = false;
    };
    rust-vim-enhanced = {
      url = "github:Iron-E/rust.vim/feature/struct-definition-identifiers";
      flake = false;
    };

    # Optional.
    secrets.url = "/home/oxa/storage/repo/nixos-config-secrets";
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
      mypkgs = final: prev: import ./pkgs { inherit (final) callPackage; };
      rust-overlay = inputs.rust-overlay.overlay;
      prefer-remote-fetch = final: prev: prev.prefer-remote-fetch final prev;

      fcitx5-qt-wayland = final: prev: {
        libsForQt5 = prev.libsForQt5.overrideScope' (finalScope: prevScope: {
          fcitx5-qt = prevScope.fcitx5-qt.overrideAttrs (old: {
            patches = old.patches or [] ++ [ ./patches/fcitx5-qt-disable-position-clamping.patch ];
          });
        });
      };

      fcitx5-gtk-wayland = final: prev: {
        fcitx5-gtk = prev.fcitx5-gtk.overrideAttrs (old: {
          version = "20211112";
          src = final.fetchFromGitHub {
            owner = "fcitx";
            repo = "fcitx5-gtk";
            rev = "96511d2f07a489fc8ae6bf2e91067ab94483edd5";
            sha256 = "FjCH+pP/yVKk/gtSg7iTj1s1fdhPKWTJevPV2U2PiNQ=";
          };
        });
      };

      flameshot-fix-desktop = final: prev: {
        flameshot = prev.flameshot.overrideAttrs (old: {
          cmakeFlags = null;
        });
      };
    };

    # Ref: https://github.com/dramforever/config/blob/63be844019b7ca675ea587da3b3ff0248158d9fc/flake.nix#L24-L28
    system-label = let inherit (inputs) self; in {
      system.configurationRevision = self.rev or null;
      system.nixos.label =
        if self.sourceInfo ? lastModifiedDate && self.sourceInfo ? shortRev
        then "${lib.substring 0 8 self.sourceInfo.lastModifiedDate}.${self.sourceInfo.shortRev}"
        else lib.warn "Repo is dirty, revision will not be available in system label" "dirty";
    };

    mkDesktopSystem = system: overlays: modules: inputs.nixpkgs.lib.nixosSystem {
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

    mkServerSystem = system: overlays: modules: inputs.nixpkgs-stable.lib.nixosSystem {
      inherit system;
      specialArgs.inputs = inputs // { nixpkgs = inputs.nixpkgs-stable; };
      modules = [
        system-label
      ] ++ modules;
    };

  in {
    nixosConfigurations = {
      invar = mkDesktopSystem "x86_64-linux"
        (with overlays; [
          # prefer-remote-fetch
          mypkgs
          rust-overlay
          fcitx5-qt-wayland
          fcitx5-gtk-wayland
          flameshot-fix-desktop
        ])
        [ ./nixos/invar/configuration.nix ];

      blacksteel = mkDesktopSystem "x86_64-linux"
        (with overlays; [
          rust-overlay
        ])
        [ ./nixos/blacksteel/configuration.nix ];

      silver = mkServerSystem "x86_64-linux"
        []
        [ ./nixos/silver/configuration.nix ];

      iso = inputs.nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [ ./nixos/iso/configuration.nix ];
        specialArgs.inputs = inputs;
      };
    };
  };
}
