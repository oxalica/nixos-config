{ config, pkgs, ... }:
{
  nixpkgsAllowUnfreeList = [
    "ark" "unrar"
    "steam" "steam-original" "steam-runtime"
    "minecraft-launcher"
    "osu-lazer"
  ];

  # Persist
  networking.networkmanager.extraConfig = ''
    [keyfile]
    path = /var/lib/NetworkManager/system-connections
  '';

  programs.wireshark.enable = true;
  programs.wireshark.package = pkgs.wireshark; # Default on is CLI.
  users.groups."wireshark".members = [ "oxa" ];

  services.xserver.dpi = 120;

  # `services.ntp` may block when stopping.
  services.timesyncd.enable = true;

  # SSD only
  services.fstrim = {
    enable = true;
    interval = "Sat";
  };

  # Local samba for VM
  services.samba = {
    enable = true;
    extraConfig = ''
      bind interfaces only = yes
      interfaces = lo virbr0
      guest account = nobody
    '';
    shares."vm_share" = {
      path = "/home/oxa/vm/share";
      writable = "yes";
    };
  };
  networking.firewall.interfaces."virbr0" = {
    allowedTCPPorts = [ 139 445 ];
    allowedUDPPorts = [ 137 138 ];
  };

  services.openssh = {
    enable = true;
    passwordAuthentication = false;
    challengeResponseAuthentication = false;
    permitRootLogin = "no";

    hostKeys = [
      {
        type = "rsa";
        path = "/var/ssh/ssh_host_rsa_key";
        bits = 4096;
      }
      {
        type = "ed25519";
        path = "/var/ssh/ssh_host_ed25519_key";
        rounds = 100;
      }
    ];
  };

  virtualisation.libvirtd = {
    enable = true;
    onBoot = "ignore";
    qemuPackage = pkgs.qemu;
  };
  users.groups."libvirtd".members = [ "oxa" ];

  services.earlyoom = {
    enable = true;
    freeMemThreshold = 5;
    freeSwapThreshold = 10;
    enableNotifications = true;
  };

  services.udev.packages = with pkgs; [ logitech-udev-rules ];

  programs.mtr.enable = true;

  programs.adb.enable = true;
  users.groups."adbusers".members = [ "oxa" ];

  # Don't work with flake.
  programs.command-not-found.enable = false;

  environment.systemPackages = with pkgs; [
    cntr # Debug nix build.
    curl
    git
    virt-manager
    solaar # Logitech devices control.
  ];
}
