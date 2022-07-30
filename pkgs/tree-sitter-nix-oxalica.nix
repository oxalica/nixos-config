{ pkgs, callPackage, fetchFromGitHub }:
callPackage /${pkgs.path}/pkgs/development/tools/parsing/tree-sitter/grammar.nix { } {
  language = "tree-sitter-nix";
  version = "unstable-2021-12-10";
  source = fetchFromGitHub {
    owner = "oxalica";
    repo = "tree-sitter-nix";
    rev = "add8eb3050a0974c1854df419c192fa4f359bcb0";
    hash = "sha256-x2Kq7t0p5AOKIHtEUHMIC6emZNoF9GE2FdKbjEfUp0E=";
  };
}
