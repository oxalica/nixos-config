{ lib, buildGoModule, fetchFromGitHub }:
buildGoModule rec {
  pname = "double-entry-generator";
  version = "1.2.0";
  src = fetchFromGitHub {
    owner = "gaocegege";
    repo = "double-entry-generator";
    rev = "v${version}";
    hash = "sha256-Bjhq/pg4wbaQFdG3EIz0E68s9NApptihW2WfcmzEr38=";
  };
  vendorSha256 = null;

  meta = with lib; {
    license = with licenses; [ asl20 ];
  };
}
