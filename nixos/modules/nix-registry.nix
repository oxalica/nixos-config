{ lib, inputs, ... }:
let
  included = [
    # "nixpkgs" # Already included in ./nix-common.nix
    "home-manager"
    "flake-utils"
    "rust-overlay"
  ];
in
{
  nix.registry = lib.genAttrs included (name: {
    from.type = "indirect";
    from.id = name;
    flake = inputs.${name};
  });

  nix.nixPath = map (name: "${name}=inputs.${name}") included;
}
