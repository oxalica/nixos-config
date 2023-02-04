# Wait for curl >7.87.0
# https://github.com/Nheko-Reborn/nheko/issues/1268
{ nheko, curl, fetchpatch, coeurl }:
assert builtins.compareVersions curl.version "7.87.0" <= 0;
let
  curl' = curl.overrideAttrs (old: {
    pname = "curl-fix-nheko";
    patches = old.patches or [ ] ++ [
      (fetchpatch {
        url = "https://github.com/curl/curl/commit/728400f875e845f72ee5602edb905f6301ade3e7.patch";
        hash = "sha256-+4breGLJDku640IlYMueNw111R91h5A+ifPxLvESxyI=";
      })
    ];
  });
in
nheko.override {
  curl = curl';
  coeurl = coeurl.override {
    curl = curl';
  };
}
