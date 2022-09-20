{ lib, source, stdenv, btrfs-progs }:
stdenv.mkDerivation rec {
  inherit (source) pname version src;

  dontUnpack = true;
  buildPhase = ''
    runHook preBuild
    mkdir -p $out/bin
    $CC $src -O2 -o $out/bin/${pname}
    runHook postBuild
  '';
  dontInstall = true;

  meta = {
    inherit (btrfs-progs.meta) platforms;
    license = with lib.licenses; [ mit ];
  };
}
