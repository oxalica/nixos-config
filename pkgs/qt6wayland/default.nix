{ lib, qt6 }:
qt6.qtwayland.overrideAttrs (old: {
  patches = old.patches or [] ++ [
    ./fix-double-free-crash.patch
  ];
})
