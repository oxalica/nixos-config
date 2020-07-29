# https://nixos.org/nixpkgs/manual/#sec-steam-play
{ lib, config, ... }:
with lib;
{
  options.oxa-config.preset.steam = mkEnableOption "configs required by steam";

  config = mkIf config.oxa-config.preset.steam {
    hardware.opengl.driSupport32Bit = true;
    hardware.pulseaudio.support32Bit = true;
  };
}
