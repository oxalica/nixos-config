{
  description = "oxalica's NixOS configuration";

  inputs = {
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixpkgs-stable.url = "github:NixOS/nixpkgs/nixos-21.11";
    nixpkgs-binfmt-fix.url = "github:NixOS/nixpkgs/pull/143060/head";
    nixpkgs-vim-plugins.url = "github:NixOS/nixpkgs/pull/148265/head";

    flake-utils.url = "github:numtide/flake-utils";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };
    rust-overlay = {
      url = "github:oxalica/rust-overlay";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
      inputs.flake-utils.follows = "flake-utils";
    };
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
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
      rust-overlay = inputs.rust-overlay.overlay;

      prefer-remote-fetch = final: prev: prev.prefer-remote-fetch final prev;

      fcitx5-wayland-fix = final: prev: {
        libsForQt5 = prev.libsForQt5.overrideScope' (finalScope: prevScope: {
          fcitx5-qt = prevScope.fcitx5-qt.overrideAttrs (old: {
            patches = old.patches or [] ++ [ ./patches/fcitx5-qt-disable-position-clamping.patch ];
          });
        });

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

      vim-plugins = prToOverlay inputs.nixpkgs-vim-plugins [ "vimPlugins" ];
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

      home-manager = { config, inputs, ... }: {
        imports = [ inputs.home-manager.nixosModules.home-manager ];
        home-manager = {
          useGlobalPkgs = true;
          useUserPackages = true;
          verbose = true;
          extraSpecialArgs = {
            inherit inputs;
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

      binfmt-fix = { config, ... }: {
        disabledModules = [ "system/boot/binfmt.nix" ];
        imports = [ (inputs.nixpkgs-binfmt-fix + "/nixos/modules/system/boot/binfmt.nix") ];
        nixpkgs.overlays = [
          (final: prev: {
            inherit (inputs.nixpkgs-binfmt-fix.legacyPackages.${config.nixpkgs.system}) wrapQemuBinfmtP;
          })
        ];
      };
    };

    mkSystem = name: system: nixpkgs: { extraOverlays ? [], extraModules ? [] }: nixpkgs.lib.nixosSystem {
      inherit system;
      specialArgs.inputs = inputs // { inherit nixpkgs; };
      specialArgs.my = import ./my.nix;
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
        extraOverlays = with overlays; [ fcitx5-wayland-fix vim-plugins ];
        extraModules = with nixosModules; [ home-manager sops binfmt-fix ];
      };

      blacksteel = mkSystem "blacksteel" "x86_64-linux" inputs.nixpkgs-unstable {
        extraModules = with nixosModules; [ home-manager sops ];
      };

      silver = mkSystem "silver" "x86_64-linux" inputs.nixpkgs-stable {
        extraModules = with nixosModules; [ sops binfmt-fix ];
      };

      lithium = mkSystem "lithium" "x86_64-linux" inputs.nixpkgs-stable { };

      iso = mkSystem "iso" "x86_64-linux" inputs.nixpkgs-stable { };
    };

  } // flake-utils.lib.eachDefaultSystem (system: {
    devShell =
      with nixpkgs-unstable.legacyPackages.${system};
      mkShell {
        packages = [ sops ssh-to-age ];
      };
  });
}
