{ lib, config, pkgs, modulesPath, ... }:
{
  imports =
    [ (modulesPath + "/installer/scan/not-detected.nix")
    ];

  boot.initrd.availableKernelModules = [ "xhci_pci" "nvme" "rtsx_pci_sdmmc" ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "kvm-intel" ];
  boot.extraModulePackages = with config.boot.kernelPackages; [
    # exfat-nofuse
    acpi_call # For TLP
    (pkgs.linuxPackages.isgx.override { inherit kernel; })
  ];

  fileSystems."/" = {
    device = "/dev/disk/by-uuid/560c1a7d-0e73-412c-b75d-6733452ec44f";
    fsType = "btrfs";
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/9C91-4441";
    fsType = "vfat";
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

  powerManagement.cpuFreqGovernor = "powersave";

  # High-DPI console
  console.font = lib.mkDefault "${pkgs.terminus_font}/share/consolefonts/ter-u28n.psf.gz";

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.timeout = 1;
}
