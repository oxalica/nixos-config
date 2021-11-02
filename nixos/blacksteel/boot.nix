{ lib, config, pkgs, modulesPath, ... }:
{
  # imports = [ (modulesPath + "/installer/scan/not-detected.nix") ];
  hardware.enableRedistributableFirmware = lib.mkDefault true;

  # Initrd.
  boot.initrd.availableKernelModules = [ "xhci_pci" "nvme" "usbhid" "rtsx_pci_sdmmc" ];
  boot.initrd.kernelModules = [ ];

  # Kernel.
  boot.kernelModules = [ "kvm-intel" ];
  boot.extraModulePackages = with config.boot.kernelPackages; [
    # exfat-nofuse
    acpi_call # For TLP
    # (pkgs.linuxPackages.isgx.override { inherit kernel; })
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
  boot.loader.systemd-boot.consoleMode = "max"; # Don't clip boot menu.
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.timeout = 1;

  # Filesystems.
  boot.initrd.luks.devices."btrfs" = {
    device = "/dev/disk/by-uuid/8e445c05-75cc-45c7-bebd-46a73cf50a74";
    allowDiscards = true;
  };

  fileSystems = let
    espDev = "/dev/disk/by-uuid/9C91-4441";
    btrfsDev = "/dev/disk/by-uuid/fbfe849d-2d2f-415f-88d3-65ded870e46b";

    btrfs = options: {
      device = btrfsDev;
      fsType = "btrfs";
      options = [ "noatime" "compress-force=zstd:1" ] ++ options;
    };
  in {
    "/boot" = {
      device = espDev;
      fsType = "vfat";
    };

    "/" = btrfs [ "subvol=/@root" ];
    "/.subvols" = btrfs [];
    "/home" = btrfs [ "subvol=/@home" ];
    "/nix" = btrfs [ "subvol=/@nix" ];
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
  # hardware.video.hidpi.enable = true; # It use 80x50 mode, which is too big and has wrong aspect ratio.
  console.font = "${pkgs.terminus_font}/share/consolefonts/ter-u28n.psf.gz";
  console.earlySetup = true;
}
