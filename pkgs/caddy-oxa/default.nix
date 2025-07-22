{
  lib,
  caddy,
}:
let
  caddy' = caddy.withPlugins {
    plugins = [
      "github.com/mholt/caddy-webdav@v0.0.0-20250609161527-33ba3cd2088c"
    ];
    hash = "sha256-Qbu+xrIz8JywcbIJx+jHQ5pLdYdKPbOVz/HXO5qHNB0=";
  };

  caddy'' = caddy'.overrideAttrs (old: {
    # NB. Overriding `version` will break the build. Because it seems to be
    # popular to use `finalAttrs.version` in build steps. Sad.
    pname = old.pname + "-oxa";
    prePatch = "pushd vendor/github.com/caddyserver/caddy/v2";
    patches =
      assert old.patches or [ ] == [ ];
      [
        ./0001-caddyauth-use-same-cost-for-users-and-fake-hash.patch
      ];
    postPatch = "popd";
  });

in
caddy''
