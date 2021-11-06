{ lib, buildGoModule, fetchFromGitHub }:
buildGoModule rec {
  pname = "double-entry-generator";
  version = "1.1.2";
  src = fetchFromGitHub {
    owner = "gaocegege";
    repo = "double-entry-generator";
    rev = "v${version}";
    hash = "sha256-6L9PQeB+mJlrfzg5M0/2oSQO95bY+DSGHVqrxjvZVA8=";
  };
  vendorSha256 = null;

  meta = with lib; {
    license = with licenses; [ asl20 ];
  };
}
