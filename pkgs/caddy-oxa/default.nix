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
    hash = "sha256-s81N2yN7i979NTbVMuX2uO6m0W4T7PUEYGOCjbSt6vk=";
  };

in
caddy'
