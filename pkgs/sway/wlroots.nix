{ lib, wlroots_0_15, fetchFromGitLab
, enableXWayland ? true
, xwayland ? null
}:
(wlroots_0_15.override {
  inherit enableXWayland xwayland;
}).overrideAttrs (old: {
  version = "unstable-2022-07-28";
  src = fetchFromGitLab {
    domain = "gitlab.freedesktop.org";
    owner = "wlroots";
    repo = "wlroots";
    rev = "30bf8a4303bc5df3cb87b7e6555592dbf8d95cf1";
    hash = "sha256-0sDD52ARoHUPPA690cJ9ctCOel4TRAn6Yr/IK7euWJc=";
  };

  meta = old.meta // {
    maintainers = with lib.maintainers; [ oxalica ];
  };
})
