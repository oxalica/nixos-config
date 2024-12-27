# This file was generated by nvfetcher, please do not modify it manually.
{ fetchgit, fetchurl, fetchFromGitHub, dockerTools }:
{
  colors = {
    pname = "colors";
    version = "94d8b2be62657e96488038b0e547e3009ed87d40";
    src = fetchurl {
      url = "https://gist.githubusercontent.com/lilydjwg/fdeaf79e921c2f413f44b6f613f6ad53/raw/94d8b2be62657e96488038b0e547e3009ed87d40/colors.py";
      sha256 = "sha256-l/RTPZp2v7Y4ffJRT5Fy5Z3TDB4dvWfE7wqMbquXdJA=";
    };
  };
  double-entry-generator = {
    pname = "double-entry-generator";
    version = "v2.7.1";
    src = fetchFromGitHub {
      owner = "deb-sig";
      repo = "double-entry-generator";
      rev = "v2.7.1";
      fetchSubmodules = false;
      sha256 = "sha256-2Y8Spj1LAVZsUgChDYDCZ63pTH+nqs2ff9xcmC+gr0c=";
    };
  };
  rime_latex = {
    pname = "rime_latex";
    version = "c863ef7f7f5ff9d909438cd48446786bf4e77cec";
    src = fetchFromGitHub {
      owner = "shenlebantongying";
      repo = "rime_latex";
      rev = "c863ef7f7f5ff9d909438cd48446786bf4e77cec";
      fetchSubmodules = false;
      sha256 = "sha256-YHWuf1DnvUgNYt4ke7W5IR4u0rJrCMJyj6JWTp5JyqI=";
    };
    date = "2024-02-03";
  };
}
