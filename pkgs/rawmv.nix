{ lib, fetchFromGitHub, rustPlatform }:
rustPlatform.buildRustPackage rec {
  pname = "rawmv";
  version = "0.1.0";

  src = fetchFromGitHub {
    owner = "oxalica";
    repo = pname;
    rev = "v${version}";
    hash = "sha256-s15siWj9dh/XOkRqAWbRLnotboIU3pG0Dspvx1EvmTA=";
  };

  cargoHash = "sha256-w5aWyJp0kxb926bTjI02Pm09I5YHCoeg7Vp2au6OZ0o=";

  meta = with lib; {
    license = with licenses; [ gpl3Only ];
  };
}
