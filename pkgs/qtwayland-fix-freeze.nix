{ qt6, fetchpatch }:
qt6.qtwayland.overrideAttrs (old: {
  patches = old.patches or [ ] ++ [
    (fetchpatch {
      url = "https://codereview.qt-project.org/gitweb?p=qt/qtwayland.git;a=patch;h=a744af148b1753a2ca0e18446cd17721443d961c";
      hash = "sha256-TlZozKezpYm90B9qFP9qv76asRdIt+5bq9E3GcmFiDc=";
    })
  ];
})

