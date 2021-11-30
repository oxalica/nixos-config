{ config, lib, pkgs, modulesPath, ... }:

{
  # imports = [ (modulesPath + "/installer/scan/not-detected.nix") ];
  hardware.enableRedistributableFirmware = lib.mkDefault true;

  boot.initrd.availableKernelModules = [ "xhci_pci" "ahci" "nvme" "usbhid" ];
  boot.initrd.kernelModules = [ "dm-snapshot" ];
  boot.kernelModules = [
    "kvm-amd"
    "nct6775" # Fan control
  ];
  boot.extraModulePackages = [ ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.systemd-boot.consoleMode = "max"; # Don't clip boot menu.
  boot.loader.efi.canTouchEfiVariables = false;
  boot.loader.timeout = 1;

  # For dev.
  boot.binfmt.emulatedSystems = [ "riscv64-linux" ];

  boot.initrd.luks.devices."unluks" = {
    device = "/dev/disk/by-uuid/21764e86-fde3-4e51-9652-da9adbdeeb34";
    preLVM = true;
    allowDiscards = true;
  };

  fileSystems = let
    btrfs = options: {
      device = "/dev/disk/by-uuid/7219f4b1-a9d1-42a4-bfc9-386fa919d44b";
      fsType = "btrfs";
      # zstd:1  W: ~510MiB/s
      # zstd:3  W: ~330MiB/s
      options = [ "compress-force=zstd:1" "noatime" ] ++ options;
    };
  in {

    "/" = {
      device = "tmpfs";
      fsType = "tmpfs";
      options = [ "defaults" "size=12G" "mode=755" ];
    };

    "/boot" = {
      device = "/dev/disk/by-uuid/DDBD-2F2B";
      fsType = "vfat";
    };

    "/.subvols" = btrfs [ ];
    "/nix" = btrfs [ "subvol=/@nix" ];
    "/var" = btrfs [ "subvol=/@var" ];
    "/home/oxa" = btrfs [ "subvol=/@home-oxa" ];
  };

  swapDevices = [
    {
      device = "/var/swapfile";
      # FIXME: Auto creation sucks on btrfs.
      # size = 16 * 1024; # 16G
    }
  ];

  systemd.tmpfiles.rules = [
    "d /tmp 1777 root root 2d"
    "q /var/tmp 1777 root root 15d"
  ];
  # We already wrote our rules.
  environment.etc."tmpfiles.d/tmp.conf".source =
    lib.mkForce (pkgs.writeText "dummy-tmp-conf" "");

  environment.etc = {
    "machine-id".source = "/var/machine-id";
    "ssh/ssh_host_rsa_key".source = "/var/ssh/ssh_host_rsa_key";
    "ssh/ssh_host_rsa_key.pub".source = "/var/ssh/ssh_host_rsa_key.pub";
    "ssh/ssh_host_ed25519_key".source = "/var/ssh/ssh_host_ed25519_key";
    "ssh/ssh_host_ed25519_key.pub".source = "/var/ssh/ssh_host_ed25519_key.pub";
  };

  # High-DPI console
  hardware.video.hidpi.enable = true;
  console.font = "${pkgs.terminus_font}/share/consolefonts/ter-v28n.psf.gz";
}
