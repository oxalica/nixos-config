{ lib, config, pkgs, modulesPath, ... }:
{
  boot.kernel.sysctl = {
    "kernel.sysrq" = 1;
    # "vm.swappiness" = 10;
    "net.ipv4.tcp_congestion_control" = "bbr";
  };

  hardware.cpu.amd.updateMicrocode = true;
  hardware.bluetooth.enable = true;

  # https://nixos.wiki/wiki/AMD_GPU#OpenCL
  hardware.opengl.extraPackages = with pkgs; [
    rocm-opencl-icd
    rocm-opencl-runtime
  ];
  services.xserver.videoDrivers = [ "amdgpu" ];

  # sound.enable = true;
  # hardware.pulseaudio.enable = true;
  # users.groups."audio".members = [ "oxa" ];

  security.rtkit.enable = true; # Better installed with pipewire.
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };
}
