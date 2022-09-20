{ source, pkgs
, enableXWayland ? true, xwayland ? null
}:
(pkgs.wlroots.override {
  inherit enableXWayland xwayland;
}).overrideAttrs (old: {
  inherit (source) version src;
})
