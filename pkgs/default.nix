{ callPackage }:
{
  double-entry-generator = callPackage ./double-entry-generator.nix {};
  rawmv = callPackage ./rawmv.nix {};
}
