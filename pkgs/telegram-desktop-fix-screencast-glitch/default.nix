{ lib, fetchpatch, telegram-desktop }:
let
  tg_owt' = telegram-desktop.tg_owt.overrideAttrs (old: {
    patches = old.patches or [] ++ [
      # WAIT: https://github.com/desktop-app/tg_owt/pull/129
      (fetchpatch {
        url = "https://github.com/oxalica/tg_owt/commit/e933a7bb3969e5215e305bd0d656da16008bc747.patch";
        hash = "sha256-8a500E2G4FP1bwJLH8RnViSkjBshWobPpW0hQiMytb0=";
      })
    ];
  });
in telegram-desktop.overrideAttrs (old: {
  buildInputs =
    lib.filter (p: p.pname != "tg_owt") old.buildInputs ++ [ tg_owt' ];
})
