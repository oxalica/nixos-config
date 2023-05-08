{
  lib,
  source,
  sway-unwrapped,
  wlroots-git,

  isNixOS ? false,
  enableXWayland ? true
}:
(sway-unwrapped.override {
  wlroots_0_16 = wlroots-git;
  inherit isNixOS enableXWayland;
}).overrideAttrs (old: {
  inherit (source) src;
  version = "git-${source.date}";

  patches = lib.filter (p: p.name or "" != "LIBINPUT_CONFIG_ACCEL_PROFILE_CUSTOM.patch") old.patches;
})
