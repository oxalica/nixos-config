{ lib, config, pkgs, modulesPath, my, ... }:
{
  imports = [
    "${modulesPath}/profiles/qemu-guest.nix"

    ../modules/zswap-enable.nix
    ./vultr-image.nix
  ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.timeout = 1;

  boot.initrd.systemd.enable = true;
  boot.initrd.availableKernelModules = [ "ahci" "xhci_pci" "virtio_pci" "sr_mod" "virtio_blk" ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ ];
  boot.extraModulePackages = [ ];

  boot.kernel.sysctl = {
    "net.ipv4.tcp_congestion_control" = "bbr";
  };

  fileSystems."/" = {
    device = "/dev/disk/by-label/nixos";
    fsType = "ext4";
  };

  # The initial partition is very small. Do not enable swap on it, or the system will freeze.
  swapDevices = [ ];

  networking.useNetworkd = true;
  networking.useDHCP = false;
  networking.interfaces.enp1s0.useDHCP = true;
  networking.firewall.enable = false; # Already have a hardware firewall.
  networking.nameservers = [
    "1.1.1.1" "1.0.0.1"
    "2606:4700:4700::1111" "2606:4700:4700::1001"
  ];

  users = {
    mutableUsers = false;
    users."oxa" = {
      isNormalUser = true;
      uid = 1000;
      group = config.users.groups.oxa.name;
      extraGroups = [ "wheel" ];

      openssh.authorizedKeys.keys = with my.ssh.identities; [ oxa ];
    };
    groups."oxa".gid = 1000;
  };

  services.getty.autologinUser = config.users.users.oxa.name;

  security.sudo.wheelNeedsPassword = false;

  nix.package = pkgs.nix;
  nix.gc.options = lib.mkForce "--delete-older-than 3d";
  nix.settings.auto-optimise-store = lib.mkForce false;
  # Avoid dependency to nixpkgs itself.
  nix.settings.nix-path = lib.mkForce "";
  nix.registry = lib.mkForce { };
  nix.nixPath = lib.mkForce [ ];

  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = false;
      KbdInteractiveAuthentication = false;
    };
  };
}
