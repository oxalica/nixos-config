{ lib, sway-unwrapped, wlroots-unstable, fetchFromGitHub, stdenv
, wayland, libxkbcommon, pcre2, json_c, libevdev
, pango, cairo, libinput, gdk-pixbuf
, wayland-protocols, libdrm, xcbutilwm
, dbus

, isNixOS ? false
, enableXWayland ? true
, systemdSupport ? stdenv.isLinux
, dbusSupport ? true
, trayEnabled ? systemdSupport && dbusSupport
}:
(sway-unwrapped.override {
  inherit isNixOS enableXWayland systemdSupport dbusSupport trayEnabled;
}).overrideAttrs (old: {
  version = "unstable-2022-07-30";

  src = fetchFromGitHub {
    owner = "swaywm";
    repo = "sway";
    rev = "9e879242fd1f1230d34337984cca565d84b932bb";
    hash = "sha256-CxfEz8Iaot8ShlNqf9aBdVnxnmlN3aUauYqGQsqpkXI=";
  };

  buildInputs = [
    wayland libxkbcommon pcre2 json_c libevdev
    pango cairo libinput gdk-pixbuf
    wayland-protocols libdrm xcbutilwm
    (wlroots-unstable.override { inherit enableXWayland; })
  ] ++ lib.optional dbusSupport dbus;

  meta = old.meta // {
    maintainers = with lib.maintainers; [ oxalica ];
  };
})
