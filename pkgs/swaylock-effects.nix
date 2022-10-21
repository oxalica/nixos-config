{ source, lib, pkgs }:
pkgs.swaylock-effects.overrideAttrs (old: {
  version = lib.removePrefix "v" source.version;
  inherit (source) src;
})
