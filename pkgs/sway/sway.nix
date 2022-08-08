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
  version = "unstable-2022-08-05";

  src = fetchFromGitHub {
    owner = "swaywm";
    repo = "sway";
    rev = "89d73beedbad2d484adc85fe114680e85d391958";
    hash = "sha256-G4QWZrdU3L23zok62vQ4OCGcUpLdM1kC5vuTcDh+mC8=";
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
