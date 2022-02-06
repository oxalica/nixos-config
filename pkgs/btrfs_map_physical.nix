# https://github.com/osandov/osandov-linux/blob/master/scripts/btrfs_map_physical.c
{ lib, stdenv, fetchurl }:
stdenv.mkDerivation rec {
  pname = "btrfs_map_physical";
  version = "2021-02-09";
  src = fetchurl {
    url = "https://raw.githubusercontent.com/osandov/osandov-linux/49aec6b85d8457fa25b5d8f6c2afb3dd4592401a/scripts/btrfs_map_physical.c";
    hash = "sha256-KyAIWrSaUJEfpFh7R3u/VYYaC8fQxoCTWb6jlayMufw=";
  };

  dontUnpack = true;

  buildPhase = ''
    runHook preBuild
    mkdir -p $out/bin
    $CC $src -O2 -o $out/bin/${pname}
    runHook postBuild
  '';

  dontInstall = true;

  meta.license = [ lib.licenses.mit ];
}
