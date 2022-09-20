{ lib, source, rustPlatform }:
rustPlatform.buildRustPackage {
  inherit (source) pname src cargoHash;
  version = lib.removePrefix "v" source.version;
  meta = {
    platforms = lib.platforms.linux;
    license = with lib.licenses; [ gpl3Only ];
  };
}
