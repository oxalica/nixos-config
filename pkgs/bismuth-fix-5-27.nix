{ plasma5Packages, fetchpatch }:
plasma5Packages.bismuth.overrideAttrs (old: {
  patches = old.patches or [ ] ++ [
    # https://github.com/Bismuth-Forge/bismuth/pull/490
    (fetchpatch {
      url = "https://github.com/Bismuth-Forge/bismuth/pull/490/commits/ce377a33232b7eac80e7d99cb795962a057643ae.patch";
      hash = "sha256-15txf7pRhIvqsrBdBQOH1JDQGim2Kh5kifxQzVs5Zm0=";
    })
  ];
})
