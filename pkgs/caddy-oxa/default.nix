{
  lib,
  caddy,
}:
let
  caddy' = caddy.withPlugins {
    plugins = [
      "github.com/mholt/caddy-webdav@v0.0.0-20250805175825-7a5c90d8bf90"
    ];
    hash = "sha256-RfoWigQXCh1DVHDLlux1BvJwk3ATWgfODNbkdX35354=";
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
