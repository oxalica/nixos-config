{
  lib,
  caddy,
}:
let
  caddy' = caddy.withPlugins {
    plugins = [
      "github.com/mholt/caddy-webdav@v0.0.0-20241008162340-42168ba04c9d"
    ];
    hash = "sha256-WxPPQdRIJNs/Cx+IP4i3jefFqksTxCRPPtVgDPEdSLM=";
  };

  caddy'' = caddy'.overrideAttrs (old: rec {
    version = "2.9.1";

    prePatch = "pushd vendor/github.com/caddyserver/caddy/v2";
    patches =
      assert old.patches or [ ] == [ ];
      [
        ./0001-caddyauth-use-same-cost-for-users-and-fake-hash.patch
      ];
    postPatch = "popd";

    ldflags = [
      "-s"
      "-w"
      "-X github.com/caddyserver/caddy/v2.CustomVersion=${version}"
    ];
  });

in
caddy''
