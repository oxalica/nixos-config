{ inputs, overlays, ... }:
inputs.nixpkgs-stable.lib.nixosSystem {
  system = "x86_64-linux";
  modules = [
    ./configuration.nix
  ];
  specialArgs.inputs = inputs // { nixpkgs = inputs.nixpkgs-stable; };
}
