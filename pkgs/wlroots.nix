{ source, pkgs, wayland-protocols
, enableXWayland ? true, xwayland ? null
}:
(pkgs.wlroots.override {
  inherit wayland-protocols;
  inherit enableXWayland xwayland;
}).overrideAttrs (old: {
  inherit (source) version src;
})
