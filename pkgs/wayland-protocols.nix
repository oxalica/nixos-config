{ source, pkgs }:
pkgs.wayland-protocols.overrideAttrs (old: {
  inherit (source) version src;
})
