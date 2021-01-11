{ lib, config, pkgs, modulesPath, ... }:
{
  boot.kernel.sysctl = {
    "kernel.sysrq" = "1";
    "net.ipv4.tcp_congestion_control" = "bbr";
  };

  services.xserver.xkbOptions = "ctrl:swapcaps";
  console.useXkbConfig = true;

  hardware.cpu.intel.updateMicrocode = true;

  hardware.bluetooth.enable = true;

  hardware.logitech.wireless.enable = true;

  hardware.pulseaudio.enable = true;
  sound.enable = true;
  # sound.mediaKeys.enable = true;
}
