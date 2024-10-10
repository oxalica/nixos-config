{ lib, pkgs, modulesPath, my, ... }:
{
  imports = [
    "${modulesPath}/profiles/qemu-guest.nix"

    ../modules/nix-common.nix
    ../modules/server-env.nix
    ../modules/zswap-enable.nix
    ./vultr-image.nix
  ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.timeout = 1;

  boot.initrd.systemd.enable = true;
  boot.initrd.availableKernelModules = [ "ahci" "xhci_pci" "sr_mod" ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ ];
  boot.extraModulePackages = [ ];

  boot.kernel.sysctl = {
    "net.ipv4.tcp_congestion_control" = "bbr";
  };

  fileSystems."/" = {
    device = "/dev/disk/by-label/nixos";
    fsType = "btrfs";
    options = [ "noatime" "compress=zstd" ];
  };
  fileSystems."/boot" = {
    device = "/dev/disk/by-label/ESP";
    fsType = "vfat";
  };

  swapDevices = [ ];

  networking.useNetworkd = true;
  networking.useDHCP = false;
  networking.interfaces.enp1s0.useDHCP = true;
  networking.firewall.enable = false; # Already have a hardware firewall.
  networking.nameservers = [
    "1.1.1.1" "1.0.0.1"
    "2606:4700:4700::1111" "2606:4700:4700::1001"
  ];

  systemd.sysusers.enable = lib.mkDefault true;
  users.mutableUsers = lib.mkDefault false;
  users.users.root.openssh.authorizedKeys.keys = with my.ssh.identities; [ oxa ];
  services.getty.autologinUser = lib.mkDefault "root";

  nix.package = pkgs.nix;
  nix.gc.options = lib.mkForce "--delete-older-than 3d";
  # Avoid dependency to nixpkgs itself.
  nix.settings.nix-path = lib.mkForce "";
  nix.registry = lib.mkForce { };
  nix.nixPath = lib.mkForce [ ];

  services.openssh = {
    enable = true;
    ports = [ 798 ];
    settings = {
      PasswordAuthentication = false;
      KbdInteractiveAuthentication = false;
      PermitRootLogin = "prohibit-password";
    };
  };
}
