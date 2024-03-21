# WAIT: https://github.com/neoclide/coc.nvim/pull/4667
{ fetchFromGitHub, buildNpmPackage }:
buildNpmPackage rec {
  pname = "coc.nvim-rename-hlgroups";
  version = "2024-03-20";

  src = fetchFromGitHub {
    owner = "neoclide";
    repo = "coc.nvim";
    rev = "b01ae44a99fd90ac095fbf101ebd234ccf0335d6";
    hash = "sha256-Ey42t7e1XAOSd0QMyqVFu7Jr9xYTwpnNAgutAgYnKXM=";
  };

  npmDepsHash = "sha256-toV0zuM8f/Jl1CiCnb/902YdranGfU/SFOkX+tkRrVY=";

  postPatch = ''
    sed "s/let revision = 'master'/let revision = '${src.rev}'/" \
      --in-place esbuild.js
  '';

  installPhase = ''
    runHook preInstall
    mkdir -p $out
    cp -r -t $out autoload bin build doc lua plugin package.json {history,LICENSE,README}.md
    runHook postInstall
  '';

  # Skip `move-docs` hook, since `doc` must be under `$out` for vim plugins.
  preFixup = "forceShare=_nothing_";
}
