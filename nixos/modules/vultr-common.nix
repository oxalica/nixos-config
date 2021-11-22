{ lib, config, pkgs, modulesPath, ... }:
{
  imports = [
    (modulesPath + "/profiles/qemu-guest.nix")

    ./vultr-image.nix
  ];

  boot.loader.grub.enable = true;
  boot.loader.grub.version = 2;
  boot.loader.grub.device = "/dev/vda";

  boot.initrd.availableKernelModules = [ "ahci" "xhci_pci" "virtio_pci" "sr_mod" "virtio_blk" ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ ];
  boot.extraModulePackages = [ ];

  fileSystems."/" = {
    device = "/dev/disk/by-label/nixos";
    fsType = "ext4";
  };

  swapDevices = [
    {
      device = "/var/swapfile";
      size = 512; # 512 MiB
    }
  ];

  networking.useDHCP = false;
  networking.interfaces.enp1s0.useDHCP = true;
  networking.firewall.enable = false; # Already have a hardware firewall.

  users = {
    groups.oxa.gid = 1000;
    users.oxa = {
      isNormalUser = true;
      uid = 1000;
      group = "oxa";
      extraGroups = [ "wheel" ];

      openssh.authorizedKeys.keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJYl9bIMoMrs8gWUmIAF42mGnKVxqY6c+g2gmE6u2E/B oxa@invar"
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICU0P/fbBnnPCVni+efxfl//NQ1jeOe4lUDH6okvLzr1 oxa@blacksteel"
      ];
    };
  };

  services.getty.autologinUser = "oxa";

  security.sudo.wheelNeedsPassword = false;

  services.openssh = {
    enable = true;
    passwordAuthentication = false;
    challengeResponseAuthentication = false;
  };
}
