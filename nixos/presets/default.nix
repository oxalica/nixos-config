{ lib, config, ... }:
with lib;
{
  imports = [
    ./base.nix
    ./china.nix
    ./console.nix
    ./desktop-kde.nix
    ./steam.nix
  ];

  options.oxa-config.presets = mkOption {
    type = with types; listOf str;
    description = "Presets to enable";
    default = [];
    example = [ "base" "console" ];
  };

  config.oxa-config.preset = listToAttrs (map (preset: {
    name = preset;
    value = true;
  }) config.oxa-config.presets);
}
