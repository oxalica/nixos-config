{ lib, source, stdenv, meson, pkg-config, ninja, systemd, bash, python3 }:
stdenv.mkDerivation {
  inherit (source) pname version src;

  nativeBuildInputs = [ meson pkg-config ninja ];
  buildInputs = [
    systemd
    bash
    (python3.withPackages (ps: with ps; [
      dbus-next
      i3ipc
      psutil
      tenacity
      xlib
    ]))
  ];

  PKG_CONFIG_SYSTEMD_SYSTEMDSYSTEMUNITDIR = "${placeholder "out"}/lib/systemd/system";
  PKG_CONFIG_SYSTEMD_SYSTEMDUSERUNITDIR = "${placeholder "out"}/lib/systemd/user";
  mesonFlags = [ "-Dcgroups=enabled" ];
}
