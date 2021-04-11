{ lib, config, pkgs, modulesPath, ... }:
{
  imports =
    [ (modulesPath + "/installer/scan/not-detected.nix")
    ];

  # Initrd.
  boot.initrd.availableKernelModules = [ "xhci_pci" "nvme" "usbhid" "rtsx_pci_sdmmc" ];
  boot.initrd.kernelModules = [ ];
  boot.initrd.luks.devices."btrfs" = {
    device = "/dev/disk/by-uuid/8e445c05-75cc-45c7-bebd-46a73cf50a74";
    allowDiscards = true;
  };

  # Kernel.
  boot.kernelModules = [ "kvm-intel" ];
  boot.extraModulePackages = with config.boot.kernelPackages; [
    # exfat-nofuse
    acpi_call # For TLP
    (pkgs.linuxPackages.isgx.override { inherit kernel; })
  ];
  boot.kernel.sysctl = {
    "kernel.sysrq" = "1";
    "vm.swappiness" = 10;
    "net.ipv4.tcp_congestion_control" = "bbr";
  };

  # For NTFS rw mount.
  boot.supportedFilesystems = [ "ntfs-3g" ];

  # Boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.timeout = 1;

  # Filesystems.
  fileSystems = let
    espDev = "/dev/disk/by-uuid/9C91-4441";
    btrfsDev = "/dev/disk/by-uuid/fbfe849d-2d2f-415f-88d3-65ded870e46b";

    btrfs = name: {
      device = btrfsDev;
      fsType = "btrfs";
      options = [ "subvol=${name}"  ];
    };
  in {
    "/" = btrfs "@root";
    "/.subvols" = btrfs "";
    "/home" = btrfs "@home";
    "/nix" = btrfs "@nix";
    "/boot" = {
      device = espDev;
      fsType = "vfat";
    };
  };

  swapDevices = [
    {
      device = "/var/swapfile";
      size = 8192; # MiB
    }
  ];

  # Misc.

  powerManagement.cpuFreqGovernor = "powersave";

  # High-resolution display.
  hardware.video.hidpi.enable = true;
  console.font = "${pkgs.terminus_font}/share/consolefonts/ter-u24n.psf.gz";
}
