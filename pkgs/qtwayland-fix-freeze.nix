{ qt6, fetchpatch }:
qt6.qtwayland.overrideAttrs (old: {
  patches = old.patches or [ ] ++ [
    (fetchpatch {
      url = "https://code.qt.io/cgit/qt/qtwayland.git/patch/?id=8ed9c8279fd568ce4222e196847b90ac4e362ee8";
      hash = "sha256-9dOkkjJTxhpOPKPOOrchRtq6uhhOXF1iaFykp7TZEnw=";
      revert = true;
    })
  ];
})

