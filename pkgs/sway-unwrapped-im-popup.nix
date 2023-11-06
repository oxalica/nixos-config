{
  sway-unwrapped,
  fetchpatch,
  isNixOS ? false,
  enableXWayland ? true,
}:
(sway-unwrapped.override {
  inherit isNixOS enableXWayland;
}).overrideAttrs (old: {
  pname = "sway-unwrapped-im-popup";
  patches = old.patches or [ ] ++ [
    (fetchpatch {
      url = "https://github.com/swaywm/sway/commit/d1c6e44886d1047b3aa6ff6aaac383eadd72f36a.patch";
      hash = "sha256-LsCoK60FKp3d8qopGtrbCFXofxHT+kOv1e1PiLSyvsA=";
    })
  ];
})
