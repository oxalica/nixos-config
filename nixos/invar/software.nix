{ config, pkgs, my, ... }:
{
  nixpkgsAllowUnfreeList = [
    "unrar"
    "steam" "steam-original" "steam-runtime"
    "minecraft-launcher"
    "osu-lazer"
  ];

  programs.wireshark.enable = true;
  programs.wireshark.package = pkgs.wireshark; # Default on is CLI.
  users.groups."wireshark".members = [ "oxa" ];

  # `services.ntp` may block when stopping.
  services.timesyncd.enable = true;

  # SSD only
  services.fstrim = {
    enable = true;
    interval = "Sat";
  };

  services.openssh = {
    enable = true;
    passwordAuthentication = false;
    kbdInteractiveAuthentication = false;
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

  # Global ssh settings. Also for remote builders.
  programs.ssh = {
    knownHosts = my.ssh.knownHosts;
    extraConfig = ''
      Include ${config.sops.secrets.ssh-hosts.path}
    '';
  };
  sops.secrets.ssh-hosts = {
    sopsFile = ../../secrets/ssh.yaml;
    mode = "0444";
  };

  virtualisation.libvirtd = {
    enable = true;
    onBoot = "ignore";
  };
  boot.kernel.sysctl."net.ipv4.ip_forward" = 1;
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

  services.transmission = {
    enable = true;
    home = "/home/transmission";
  };
  users.groups."transmission".members = [ "oxa" ];

  environment.systemPackages = with pkgs; [
    cntr # Debug nix build.
    curl
    git
    virt-manager
    solaar # Logitech devices control.
    rawmv # Subvolume operations.
    compsize
  ];
}
