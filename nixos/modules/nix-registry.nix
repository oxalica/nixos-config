{ lib, inputs, ... }:
{
  nix.registry = lib.genAttrs [
    "nixpkgs"
    "flake-utils"
    "rust-overlay"
  ] (name: {
    from.type = "indirect";
    from.id = name;
    flake = inputs.${name};
  });
}
