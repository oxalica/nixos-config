{ config, pkgs, ... }:

{
  nixpkgsAllowUnfreeList = [
    "ark" "unrar"
    "vscode-extension-ms-vscode-cpptools" "vscode-extension-ms-vscode-remote-remote-ssh"
    "steam" "steam-original" "steam-runtime"
    "minecraft-launcher"
    "osu-lazer"
    "typora"
  ];

  services.xserver.dpi = 144;

  services.openssh = {
    enable = true;
    forwardX11 = true;
    passwordAuthentication = false;
    challengeResponseAuthentication = false;
    permitRootLogin = "no";
  };

  networking.firewall = {
    logRefusedConnections = false;
  };

  /*
  services.tlp = {
    enable = true;
    extraConfig = ''
      START_CHARGE_THRESH_BAT0=85
      STOP_CHARGE_THRESH_BAT0=90
    '';
  };
  */

  # services.printing.enable = true; # CUPS

  # services.transmission = {
  #   enable = true;
  #   home = "/home/transmission";
  # };
  # users.groups."transmission".members = [ "oxa" ];

  # services.fprintd.enable = true;
  # services.fprintd.package = pkgs.fprintd-thinkpad;

  programs.adb.enable = true;
  users.groups."adbusers".members = [ "oxa" ];

  # programs.wireshark.enable = true;
  # programs.wireshark.package = pkgs.wireshark;
  # users.groups."wireshark".members = [ "oxa" ];

  # SSE Only
  services.fstrim = {
    enable = true;
    interval = "Wed";
  };

  services.timesyncd.enable = true;

  services.earlyoom = {
    enable = true;
    enableNotifications = true;
  };

  programs.mtr.enable = true;

  environment.systemPackages = with pkgs; [
    cntr
    curl
    ltunify
    virt-manager
  ];
}
