{ lib, wlroots_0_15, fetchFromGitLab
, enableXWayland ? true
, xwayland ? null
}:
(wlroots_0_15.override {
  inherit enableXWayland xwayland;
}).overrideAttrs (old: {
  version = "unstable-2022-08-03";
  src = fetchFromGitLab {
    domain = "gitlab.freedesktop.org";
    owner = "wlroots";
    repo = "wlroots";
    rev = "3baf2a6bcfc4cb86c364f5724aaec80f28715a01";
    hash = "sha256-bV3TLiCgptpKoUKLiH/5RMtiIsfn0hawdaCEHQFB6WY=";
  };

  meta = old.meta // {
    maintainers = with lib.maintainers; [ oxalica ];
  };
})
