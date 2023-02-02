{ alacritty, fetchFromGitHub, rustPlatform }:
alacritty.overrideAttrs (old: rec {
  version = "fractional-scale";

  src = fetchFromGitHub {
    inherit (old.src) owner repo;
    rev = "3354203e571e427b7152999d13af8a1cbd14e0d8";
    hash = "sha256-KxslwPEjVvd6KWWwPAFra+aSCMdHaFX/GQyHyrYGrRs=";
  };

  cargoDeps = rustPlatform.fetchCargoTarball {
    inherit src;
    hash = "sha256-NBAI4Qix4vRE1CIRizEXl9iIjfZpIyNKqUfgQLnZUpg=";
  };
})
