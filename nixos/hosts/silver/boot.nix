{ config, lib, pkgs, modulesPath, ... }:

{
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
  ];

  # Initrd.
  boot.initrd.availableKernelModules = [ "xhci_pci" "ahci" "usb_storage" "sd_mod" ];
  boot.kernelModules = [ "kvm-intel" ];
  boot.extraModulePackages = [ ];

  # Kernel.
  boot.kernel.sysctl = {
    "net.ipv4.tcp_congestion_control" = "bbr";
    "vm.swappiness" = 30;
  };

  # Boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.timeout = 1;

  # Filesystems.
  fileSystems."/" = {
    device = "/dev/disk/by-uuid/3c855cef-48db-4ba5-84fc-0d8055fbe7bd";
    fsType = "ext4";
  };
  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/F800-4055";
    fsType = "vfat";
  };

  # swapDevices = [
  #   {
  #     device = "/var/swapfile";
  #     size = 8192; # MiB
  #     randomEncryption = {
  #       enable = true;
  #       cipher = "aes-xts-plain64";
  #     };
  #   }
  # ];

  # Misc.
  powerManagement.cpuFreqGovernor = "ondemand";
}
