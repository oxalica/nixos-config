{ pkgs, sway-unwrapped
, withBaseWrapper ? true
, extraSessionCommands ? ""
, withGtkWrapper ? false
, extraOptions ? []
, isNixOS ? false
, enableXWayland ? true
, dbusSupport ? true
}:
pkgs.sway.override {
  inherit withBaseWrapper extraSessionCommands withGtkWrapper extraOptions isNixOS enableXWayland dbusSupport;
  inherit sway-unwrapped;
}
