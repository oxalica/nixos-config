{ lib, pkgs, inputs }:
let
  inherit (builtins) readDir;
  inherit (lib) mapAttrs' filterAttrs;

  sources = pkgs.callPackage ./_sources/generated.nix { };
  entries = removeAttrs (readDir ./.) [ "_sources" "default.nix" "nvfetcher.toml" ];

  self = mapAttrs' (file: _: rec {
    name = lib.removeSuffix ".nix" file;
    value = pkgs.newScope (self // {
      inherit inputs;
      source = sources.${name} or null;
    }) ./${file} { };
  }) entries;
in
# Remove unsupported or broken packages.
filterAttrs
  (name: drv: drv ? meta.platforms -> lib.meta.availableOn pkgs.hostPlatform drv)
  self
