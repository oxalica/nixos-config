{ presets }:

{ ... }:
let
  allPresets = {
    console = ./presets/console;
    desktop = ./presets/desktop;
    base = ./presets/base.nix;
    china = ./presets/china.nix;
    steam = ./presets/steam.nix;
  };
in {
  imports = map (name: import allPresets.${name}) presets;
}
