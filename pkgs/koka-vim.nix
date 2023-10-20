{ stdenvNoCC, inputs }:
stdenvNoCC.mkDerivation {
  pname = "koka.vim";

  version = "git-${inputs.koka-vim.shortRev}";
  src = inputs.koka-vim;

  dontBuild = true;

  installPhase = ''
    runHook preInstall
    cp -r $src/support/vim $out
    runHook postInstall
  '';
}
