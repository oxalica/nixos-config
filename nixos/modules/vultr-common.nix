{ lib, config, pkgs, modulesPath, my, ... }:
{
  imports = [
    (modulesPath + "/profiles/qemu-guest.nix")

    ./vultr-image.nix

    ../modules/user-oxa.nix
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
      size = 1024; # 512 MiB
    }
  ];

  networking.useDHCP = false;
  networking.interfaces.enp1s0.useDHCP = true;
  networking.firewall.enable = false; # Already have a hardware firewall.

  users.users."oxa".openssh.authorizedKeys.keys = [
    my.ssh.identities.oxa-invar
    my.ssh.identities.oxa-blacksteel
  ];

  services.getty.autologinUser = "oxa";

  security.sudo.wheelNeedsPassword = false;

  services.openssh = {
    enable = true;
    passwordAuthentication = false;
    challengeResponseAuthentication = false;
  };
}
