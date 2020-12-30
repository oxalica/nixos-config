{ nixpkgs, flake-config, ... }:
nixpkgs.lib.nixosSystem {
  system = "x86_64-linux";
  modules = [
    flake-config
    ./configuration.nix
  ];
}
