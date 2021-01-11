{ pkgs, config, ... }:
{
  boot = {
    # earlyVconsoleSetup = true;

    loader.systemd-boot.enable = true;
    loader.efi.canTouchEfiVariables = true;
    loader.timeout = 1;

    extraModulePackages = with config.boot.kernelPackages; [
      # exfat-nofuse
      acpi_call # For TLP
      (pkgs.linuxPackages.isgx.override { inherit kernel; })
    ];

    kernelParams = [
      # "quite"
      # "i915.fastboot=1"
      # "i915.enable_gvt=1" # Auto enabled
    ];

    kernel.sysctl = {
      "kernel.sysrq" = "1";
      "net.ipv4.tcp_congestion_control" = "bbr";
    };
  };

  swapDevices = [
    {
      # 8G
      device = "/dev/disk/by-partuuid/3fb15a6f-55f6-cd48-8a08-875f15f6d274";
      randomEncryption = {
        enable = true;
        cipher = "aes-xts-plain64";
      };
    }
  ];

  services.xserver.xkbOptions = "ctrl:swapcaps";
  console.useXkbConfig = true;

  hardware.cpu.intel.updateMicrocode = true;

  hardware.bluetooth.enable = true;

  hardware.logitech.wireless.enable = true;

  hardware.pulseaudio.enable = true;
  sound.enable = true;
  # sound.mediaKeys.enable = true;
}
