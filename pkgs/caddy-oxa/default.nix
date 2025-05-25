{
  lib,
  caddy,
}:
let
  caddy' = caddy.withPlugins {
    plugins = [
      "github.com/mholt/caddy-webdav@v0.0.0-20241008162340-42168ba04c9d"
    ];
    hash = "sha256-fURqPgMpZ17ubhvr+JmY8jBgDaKBb654wo9Z4izjlro=";
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
