{ lib, config, pkgs, modulesPath, my, ... }:
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
  boot.initrd.luks = {
    gpgSupport = true;
    devices."btrfs" = {
      device = "/dev/disk/by-uuid/8e445c05-75cc-45c7-bebd-46a73cf50a74";
      allowDiscards = true;
      gpgCard.gracePeriod = 15;
      gpgCard.encryptedPass = ./luks-encrypted-pass.gpg.asc;
      gpgCard.publicKey = my.gpg.publicKeyFile;
    };
  };

  fileSystems = {
    "/" = {
      device = "/dev/disk/by-uuid/fbfe849d-2d2f-415f-88d3-65ded870e46b";
      fsType = "btrfs";
      options = [ "noatime" "compress-force=zstd:1" "subvol=@" ];
    };

    "/boot" = {
      device = "/dev/disk/by-uuid/9C91-4441";
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
  console.font = "${pkgs.terminus_font}/share/consolefonts/ter-v28n.psf.gz";
}
