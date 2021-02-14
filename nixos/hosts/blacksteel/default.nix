{ inputs, overlays, ... }:
inputs.nixpkgs.lib.nixosSystem {
  system = "x86_64-linux";
  modules = [
    inputs.home-manager.nixosModules.home-manager
    { nixpkgs.overlays = with overlays; [ rust-overlay isgx ]; }
    ./configuration.nix
  ];
  specialArgs.inputs = inputs;
}
