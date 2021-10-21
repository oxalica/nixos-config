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
    xdgify-overlay = {
      url = "github:oxalica/xdgify-overlay";
      # url = "/home/oxa/storage/repo/xdgify-overlay";
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
      rust-overlay = inputs.rust-overlay.overlay;
      xdgify-overlay = inputs.xdgify-overlay.overlay;

      fcitx5-qt-wayland = final: prev: {
        libsForQt5 = prev.libsForQt5.overrideScope' (finalScope: prevScope: {
          fcitx5-qt = prevScope.fcitx5-qt.overrideAttrs (old: {
            patches = old.patches or [] ++ [ ./patches/fcitx5-qt-disable-position-clamping.patch ];
          });
        });
      };

      # FIXME: https://github.com/NixOS/nixpkgs/issues/141873
      flameshot-fix = final: prev: {
        flameshot = prev.flameshot.overrideAttrs (old: {
          patches = old.patches or [] ++ [
            (final.fetchpatch {
              url = "https://github.com/flameshot-org/flameshot/commit/7977cbb52c2d785abd0d85d9df5991e8f7cae441.patch";
              sha256 = "sha256-wWa9Y+4flBiggOMuX7KQyL+q3f2cALGeQBGusX2x6sk=";
            })
          ];
          postInstall = old.postInstall or "" + ''
            sed -E "s#Exec=[^ ]*flameshot#Exec=$out#" \
              --in-place "$out/share/applications/org.flameshot.Flameshot.desktop"
          '';
        });
      };

      # FIXME: https://github.com/alacritty/alacritty/commit/58985a4dcbe464230b5d2566ee68e2d34a1788c8
      alacritty-pty-error = final: prev: {
        alacritty = prev.alacritty.overrideAttrs (old: {
          patches = old.patches or [] ++ [
            (final.fetchpatch {
              url = "https://github.com/alacritty/alacritty/commit/58985a4dcbe464230b5d2566ee68e2d34a1788c8.patch";
              sha256 = "sha256-Z6589yRrQtpx3/vNqkMiGgGsLysd/QyfaX7trqX+k5c=";
            })
          ];
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
          rust-overlay
          xdgify-overlay
          fcitx5-qt-wayland
          flameshot-fix
          alacritty-pty-error
        ])
        [ ./nixos/hosts/invar/configuration.nix ];

      blacksteel = mkDesktopSystem "x86_64-linux"
        (with overlays; [ rust-overlay ])
        [ ./nixos/hosts/blacksteel/configuration.nix ];

      silver = mkServerSystem "x86_64-linux"
        []
        [ ./nixos/hosts/silver/configuration.nix ];

      iso = inputs.nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [ ./nixos/hosts/iso/configuration.nix ];
        specialArgs.inputs = inputs;
      };
    };
  };
}
