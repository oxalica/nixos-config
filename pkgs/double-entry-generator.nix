{ lib, source, buildGoModule }:
buildGoModule {
  inherit (source) pname src;
  vendorHash = "sha256-Xedva9oGteOnv3rP4Wo3sOHIPyuy2TYwkZV2BAuxY4M=";
  version = lib.removePrefix "v" source.version;
  subPackages = [ "." ];
  meta.license = with lib.licenses; [ asl20 ];
}
