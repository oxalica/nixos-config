{ waybar, fetchpatch }:
waybar.overrideAttrs (old: {
  patches = old.patches or [ ] ++ [
    (fetchpatch {
      url = "https://github.com/Alexays/Waybar/commit/eedd1f8e6a3dfd305af9359209e02edd5b68d40a.patch";
      hash = "sha256-gux7X70k0MibN1QuoynuRLIT+Dxb+cVnwRqGY3adZX0=";
    })
  ];
})
