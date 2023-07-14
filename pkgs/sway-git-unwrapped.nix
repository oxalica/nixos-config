{
  lib,
  source,
  sway-unwrapped,
  wlroots-git,
  fetchpatch,

  isNixOS ? false,
  enableXWayland ? true
}:
(sway-unwrapped.override {
  wlroots = wlroots-git;
  inherit isNixOS enableXWayland;
}).overrideAttrs (old: {
  inherit (source) src;
  version = "git-${source.date or "unknown"}";

  patches =
    lib.filter (p: p.name or "" != "LIBINPUT_CONFIG_ACCEL_PROFILE_CUSTOM.patch") old.patches ++ [
      # text_input: Implement input-method popups
      # https://github.com/swaywm/sway/pull/7226
      (fetchpatch {
        url = "https://github.com/swaywm/sway/pull/7226/commits/53d4cf1b93de202da22b7f2132e2086eace63ff6.patch";
        hash = "sha256-SZj7W8Iji7KBxBSsj+DKQb64dedEwrvHeMNhNDtNNAs=";
      })
    ];
})
