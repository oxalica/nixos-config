{ lib, inputs, ... }:
{
  nix.registry = lib.genAttrs [
    "nixpkgs"
    "home-manager"
    "flake-utils"
    "rust-overlay"
  ] (name: {
    from.type = "indirect";
    from.id = name;
    flake = inputs.${name};
  });
}
