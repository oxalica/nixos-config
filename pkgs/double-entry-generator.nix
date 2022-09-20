{ lib, source, buildGoModule }:
buildGoModule {
  inherit (source) pname src vendorHash;
  version = lib.removePrefix "v" source.version;
  subPackages = [ "." ];
  meta.license = with lib.licenses; [ asl20 ];
}
