{ cntr, fetchpatch }:
cntr.overrideAttrs (old: {
  patches = old.patches or [ ] ++ [
    # See: <https://github.com/Mic92/cntr/pull/422>
    (fetchpatch {
      url = "https://github.com/Mic92/cntr/pull/422/commits/12b15c9b5216631751520c82cf072014e5ca88b6.patch";
      hash = "sha256-g79BKM56a1e8KNH+k34t4Z5XPBEmhWYlsuos5BoD40A=";
    })
  ];
})
