{ pkgs, callPackage, fetchFromGitHub }:
callPackage /${pkgs.path}/pkgs/development/tools/parsing/tree-sitter/grammar.nix { } {
  language = "tree-sitter-bash";
  version = "unstable-2021-12-16";
  source = fetchFromGitHub {
    owner = "tree-sitter";
    repo = "tree-sitter-bash";
    rev = "275effdfc0edce774acf7d481f9ea195c6c403cd";
    hash = "sha256-+XJ6ivsp0q08KWhwEQnAYpU88/gggf6or6oxga5k0ZE=";
  };
}
