{
  lib,
  sway-unwrapped,
  fetchFromGitHub,
  wlroots_0_17,
  isNixOS ? false,
  enableXWayland ? true,
}:
(sway-unwrapped.override {
  inherit isNixOS enableXWayland;
  wlroots_0_16 = wlroots_0_17;
}).overrideAttrs (old: rec {
  version = "1.9.0";
  src = fetchFromGitHub {
    owner = "swaywm";
    repo = "sway";
    rev = version;
    hash = "sha256-/6+iDkQfdLcL/pTJaqNc6QdP4SRVOYLjfOItEu/bZtg=";
  };
  patches = lib.filter
    (p: p.name or null != "LIBINPUT_CONFIG_ACCEL_PROFILE_CUSTOM.patch")
    old.patches;
})
