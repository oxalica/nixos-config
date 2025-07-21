{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
}:

stdenvNoCC.mkDerivation {
  pname = "urw-base35-fonts";
  version = "2020-09-10";

  src = fetchFromGitHub {
    owner = "ArtifexSoftware";
    repo = "urw-base35-fonts";
    rev = "20200910";
    hash = "sha256-YQl5IDtodcbTV3D6vtJi7CwxVtHHl58fG6qCAoSaP4U=";
  };

  installPhase = ''
    runHook preInstall
    install -Dm644 -t $out/share/fonts/urw-base35-fonts fonts/*.{afm,otf,t1,ttf}
    runHook postInstall
  '';

  meta = with lib; {
    description = "URW++ base 35 font set";
    homepage = "https://github.com/ArtifexSoftware/urw-base35-fonts";
    license = licenses.agpl3Only;
    maintainers = [ ];
    platforms = platforms.all;
  };
}
