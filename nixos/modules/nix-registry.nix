{ lib, inputs, ... }:
{
  nix.registry = lib.mapAttrs (name: value: {
    flake = value;
  }) inputs;
}
