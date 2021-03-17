{ inputs, overlays, ... }:
inputs.nixpkgs.lib.nixosSystem {
  system = "x86_64-linux";
  modules = [
    inputs.home-manager.nixosModules.home-manager
    { nixpkgs.overlays = with overlays; [ rust-overlay isgx partition-manager ]; }
    ./configuration.nix
    ({ lib, ... }: {
      options.home-manager.users = with lib.types; lib.mkOption {
        type = attrsOf (submoduleWith {
          modules = [ ];
          specialArgs = {
            inherit inputs;
          };
        });
      };
    })
  ];
  specialArgs.inputs = inputs;
}
