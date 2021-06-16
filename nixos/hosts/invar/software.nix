{ config, pkgs, ... }:
{
  nixpkgsAllowUnfreeList = [
    "ark" "unrar"
    "vscode-extension-ms-toolsai-jupyter"
    "vscode-extension-ms-vscode-cpptools"
    "vscode-extension-ms-vscode-remote-remote-ssh"
    "steam" "steam-original" "steam-runtime"
    "minecraft-launcher"
    "osu-lazer"
    "typora"
  ];

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
  };

  virtualisation.libvirtd = {
    enable = true;
    onBoot = "ignore";
    qemuPackage = pkgs.qemu_kvm;
  };
  users.groups."libvirtd".members = [ "oxa" ];

  services.earlyoom = {
    enable = true;
    freeMemThreshold = 5;
    freeSwapThreshold = 10;
    enableNotifications = true;
  };

  programs.mtr.enable = true;

  programs.adb.enable = true;
  users.groups."adbusers".members = [ "oxa" ];

  environment.systemPackages = with pkgs; [
    cntr # Debug nix build.
    curl
    git
    ltunify # Logitech Unifying receivers.
    virt-manager
  ];
}
