{
  lib,
  caddy,
}:
let
  caddy' = caddy.withPlugins {
    # How to update this:
    # <https://github.com/NixOS/nixpkgs/pull/358586#issuecomment-2564016652>
    plugins = [
      "github.com/mholt/caddy-webdav@v0.0.0-20260127042217-fa2f366b0d75"
    ];
    hash = "sha256-W7JhRazsft7Fhk2ArGzlKPTh0aXN5YlABRp6+lzjd1A=";
  };

in
caddy'
