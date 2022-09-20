{ pkgs, source, callPackage }:
callPackage /${pkgs.path}/pkgs/development/tools/parsing/tree-sitter/grammar.nix { } {
  language = source.pname;
  inherit (source) version;
  source = source.src;
}
