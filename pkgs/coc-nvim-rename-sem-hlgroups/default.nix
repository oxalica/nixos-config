# From: https://github.com/neoclide/coc.nvim/pull/4667
{ fetchFromGitHub, buildNpmPackage }:
buildNpmPackage rec {
  pname = "coc.nvim-rename-hlgroups";
  version = "2023-10-19";

  src = fetchFromGitHub {
    owner = "neoclide";
    repo = "coc.nvim";
    rev = "e3f91b5ed551ae95d1f5c3b75f557f188ad17b52";
    hash = "sha256-tPuwDO9UUJV3HiCYtBDcx2vDf9WWV5Ca6GusUuNklAI=";
  };

  npmDepsHash = "sha256-voD1Mq2QSL/QTpeHhdyPgm1P/sRUzTUAuGW8x5SRkQI=";

  patches = [
    ./0001-feat-semanticTokens-rename-highlight-groups.patch
  ];

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
