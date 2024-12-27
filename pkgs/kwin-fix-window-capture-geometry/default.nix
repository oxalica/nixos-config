# Bug: <https://bugs.kde.org/show_bug.cgi?id=497571>
# Patch: https://invent.kde.org/plasma/kwin/-/commit/b6e6000d9729f740f9a17cf4d4517703a8da09fa
# Backport: https://invent.kde.org/plasma/kwin/-/commit/4048d208f72b74f2393e6f129a1802ae447f228b
{
  kdePackages,
  fetchpatch,
}:
kdePackages.kwin.overrideAttrs (oldAttrs: {
  patches = oldAttrs.patches or [ ] ++ [
    (fetchpatch {
      url = "https://invent.kde.org/plasma/kwin/-/commit/4048d208f72b74f2393e6f129a1802ae447f228b.patch";
      hash = "sha256-dWIg19tQLyHeHDXw+op7h/LrS6fW089sbO/iZF1fNyQ=";
    })
  ];
})
