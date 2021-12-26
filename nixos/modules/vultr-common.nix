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

  # The initial partition is very small. Do not enable swap on it, or the system will freeze.
  swapDevices = [ ];

  networking.useDHCP = false;
  networking.interfaces.enp1s0.useDHCP = true;
  networking.firewall.enable = false; # Already have a hardware firewall.

  users.users."oxa".openssh.authorizedKeys.keys = [
    my.ssh.identities.oxa-invar
    my.ssh.identities.oxa-blacksteel
    my.ssh.identities.invar
    my.ssh.identities.blacksteel
  ];

  services.getty.autologinUser = "oxa";

  security.sudo.wheelNeedsPassword = false;

  nix.autoOptimiseStore = lib.mkForce false;

  services.openssh = {
    enable = true;
    passwordAuthentication = false;
    challengeResponseAuthentication = false;
  };
}
