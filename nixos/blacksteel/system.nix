{ lib, config, pkgs, modulesPath, ... }:
{
  services.xserver.xkbOptions = "ctrl:swapcaps";
  console.useXkbConfig = true;

  hardware.cpu.intel.updateMicrocode = true;

  hardware.bluetooth.enable = true;

  hardware.logitech.wireless.enable = true;

  hardware.pulseaudio.enable = true;
  sound.enable = true;
  # sound.mediaKeys.enable = true;
}
