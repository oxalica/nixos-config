{ config, lib, pkgs, modulesPath, ... }:

{
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
  ];

  boot.initrd.availableKernelModules = [ "xhci_pci" "ahci" "nvme" "usbhid" ];
  boot.initrd.kernelModules = [ "dm-snapshot" ];
  boot.kernelModules = [
    "kvm-amd"
    "nct6775" # Fan control
  ];
  boot.extraModulePackages = [ ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = false;
  boot.loader.timeout = 1;

  # For dev.
  boot.binfmt = {
    emulatedSystems = [ "riscv64-linux" "aarch64-linux" ];
    registrations."riscv64-linux" = {
      preserveArgvZero = true;
      interpreter = let
        qemu = (lib.systems.elaborate { system = "riscv64-linux"; }).emulator pkgs;
      in lib.mkForce ''${qemu} -0 "$2" "$1" "''${@:3}" #'';
    };
    registrations."aarch64-linux".preserveArgvZero = true;
  };

  boot.initrd.luks.devices."unluks" = {
    device = "/dev/disk/by-uuid/21764e86-fde3-4e51-9652-da9adbdeeb34";
    preLVM = true;
    allowDiscards = true;
  };

  fileSystems = {
    "/" = {
      device = "/dev/disk/by-uuid/b009a0bd-0db7-4ec5-b6d0-ff290488d6a4";
      fsType = "ext4";
    };

    "/boot" = {
      device = "/dev/disk/by-uuid/DDBD-2F2B";
      fsType = "vfat";
    };

    "/.subvols" = {
      device = "/dev/disk/by-uuid/7219f4b1-a9d1-42a4-bfc9-386fa919d44b";
      fsType = "btrfs";
    };

    "/home/oxa" = {
      device = "/dev/disk/by-uuid/7219f4b1-a9d1-42a4-bfc9-386fa919d44b";
      fsType = "btrfs";
      options = [ "subvol=@home-oxa,user_subvol_rm_allowed" ];
    };
  };

  swapDevices = [
    {
      device = "/var/swapfile";
      size = 16 * 1024; # 16G
    }
  ];

  # High-DPI console
  console.font = lib.mkDefault "${pkgs.terminus_font}/share/consolefonts/ter-u28n.psf.gz";
  console.earlySetup = true;
}
