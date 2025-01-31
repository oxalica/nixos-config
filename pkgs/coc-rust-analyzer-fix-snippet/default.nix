# See: https://github.com/fannheyward/coc-rust-analyzer/issues/1279
{
  lib,
  fetchFromGitHub,
  buildNpmPackage,
  vimPlugins,
}:
let
  nodePkg = buildNpmPackage rec {
    pname = "coc-rust-analyzer";
    version = "0-unstable-2025-01-20";

    src = fetchFromGitHub {
      owner = "fannheyward";
      repo = pname;
      rev = "a4d6aa3a5d7fcf9e701a687f5a6953067ab55cb7";
      hash = "sha256-/890Ns1LFc/OVN4ZxYf9Kr8etXooeK2YUZW1DdV/mrw=";
    };
    npmDepsHash = "sha256-lowD4iS/5moizMHe9cFqX2h/2eAx2RIL/LaTq+IduvU=";

    meta.license = lib.licenses.mit;
  };

  vimPkg = vimPlugins.coc-rust-analyzer.overrideAttrs {
    src = "${nodePkg}/lib/node_modules/coc-rust-analyzer";
  };

in
vimPkg
