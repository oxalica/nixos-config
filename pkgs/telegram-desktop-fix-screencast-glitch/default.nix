{ lib, fetchpatch, telegram-desktop }:
let
  tg_owt' = telegram-desktop.tg_owt.overrideAttrs (old: {
    patches = old.patches or [] ++ [
      (fetchpatch {
        url = "https://webrtc-review.googlesource.com/changes/src~349881/revisions/3/patch?download";
        decode = "base64 -d";
        stripLen = 1;
        extraPrefix = "src/";
        hash = "sha256-/zMTejwEODfNDBLFaZ9Q15kZnfubUocBx5qXzb297cE=";
      })
    ];
  });
in telegram-desktop.overrideAttrs (old: {
  buildInputs =
    lib.filter (p: p.pname != "tg_owt") old.buildInputs ++ [ tg_owt' ];
})
