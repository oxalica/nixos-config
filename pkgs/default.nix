{ callPackage }:
{
  btrfs_map_physical = callPackage ./btrfs_map_physical.nix { };

  double-entry-generator = callPackage ./double-entry-generator.nix { };

  rawmv = callPackage ./rawmv.nix { };

  rime_latex = callPackage ./rime_latex.nix { };

  sway-unstable = callPackage ./sway { };

  tree-sitter-bash-unstable = callPackage ./tree-sitter-bash-unstable.nix { };

  tree-sitter-nix-oxalica = callPackage ./tree-sitter-nix-oxalica.nix { };
}
