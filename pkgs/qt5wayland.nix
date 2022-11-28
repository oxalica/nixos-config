{ lib, qt5 }:
qt5.qtwayland.overrideAttrs (old: {
  patches = old.patches or [] ++ [
    ./qt6wayland/fix-double-free-crash.patch
  ];
})
