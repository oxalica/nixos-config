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
    hash = "sha256-itDJ76e3pNZmG4cAX07cuu+Vx2qLfvp9ljfu5ln4WDc=";
  };

in
caddy'
