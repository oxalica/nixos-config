{ callPackage, sway
, withBaseWrapper ? true
, extraSessionCommands ? ""
, withGtkWrapper ? false
, extraOptions ? []
, isNixOS ? false
, enableXWayland ? true
, dbusSupport ? true
}:
sway.override {
  inherit withBaseWrapper extraSessionCommands withGtkWrapper extraOptions isNixOS enableXWayland dbusSupport;
  sway-unwrapped = callPackage ./sway.nix {
    wlroots-unstable = callPackage ./wlroots.nix { };
  };
}
