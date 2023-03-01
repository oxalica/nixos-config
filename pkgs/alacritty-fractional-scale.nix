{ alacritty, fetchFromGitHub, rustPlatform }:
alacritty.overrideAttrs (old: rec {
  version = "0.12.0-rc1";

  src = fetchFromGitHub {
    inherit (old.src) owner repo;
    rev = "refs/tags/v${version}";
    hash = "sha256-ai8Gpcd+u4emewMtA63cKa700ZvZRIHoMwRSY7p/FIE=";
  };

  cargoDeps = rustPlatform.fetchCargoTarball {
    inherit src;
    hash = "sha256-DwGpliPYqkMh8ReLq13neiPDDRo+ZrLFteinSo4uDaA=";
  };
})
