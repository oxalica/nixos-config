{ source, pkgs, stdenv
, isNixOS ? false
, enableXWayland ? true
, systemdSupport ? stdenv.isLinux
, dbusSupport ? true
, trayEnabled ? systemdSupport && dbusSupport
}:
(pkgs.sway-unwrapped.override {
  inherit isNixOS enableXWayland systemdSupport dbusSupport trayEnabled;
}).overrideAttrs (old: {
  inherit (source) version src;

  buildInputs = with pkgs; with xorg; [
    wayland libxkbcommon pcre2 json_c libevdev
    pango cairo libinput gdk-pixbuf
    wayland-protocols libdrm xcbutilwm
    (pkgs.wlroots_0_16.override { inherit enableXWayland; })
  ] ++ lib.optional dbusSupport dbus;
})
