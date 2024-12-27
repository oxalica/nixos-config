{
  caddy,
  fetchpatch,
}:
let
  caddy' = caddy.overrideAttrs (old: {
    patches = old.patches or [ ] ++ [
      # caddyauth: use same cost for users and fake hash
      (fetchpatch {
        url = "https://github.com/oxalica/caddy/commit/b7a5e89fa55075cb2522a4185e730c7c1f3768b6.patch";
        hash = "sha256-A01EbLJRvzDxpPyWm4TKlcUT+SsmaSzQ9q+cvZzIIG4=";
      })
    ];
  });

  caddy'' = caddy'.withPlugins {
    plugins = [
      "github.com/mholt/caddy-webdav@v0.0.0-20241008162340-42168ba04c9d"
    ];
    hash = "sha256-Ui9M9/CQLEDBbDoBuejZeP2eIutlfcgYKFkGROR+sso=";
  };

in
caddy''
