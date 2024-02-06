{ pkgs, my, ... }:
{
  imports = [ ../l10n.nix ];

  environment.systemPackages = with pkgs.plasma5Packages; [
    ark
    filelight
    plasma-browser-integration
    my.pkgs.bismuth-fix-5-27
  ];

  programs = {
    partition-manager.enable = true;
    kdeconnect.enable = true;
    dconf.enable = true;
  };

  nixpkgs.config.firefox.enablePlasmaBrowserIntegration = true;

  services.xserver = {
    enable = true;
    xkb.layout = "us";

    displayManager = {
      sddm.enable = true;
      defaultSession = "plasmawayland";
    };

    desktopManager.plasma5 = {
      enable = true;
      runUsingSystemd = true;

      kdeglobals.KDE.SingleClick = false;
    };
  };

  security.pam.services.sddm.enableKwallet = true;

  networking.networkmanager = {
    enable = true;
    wifi.macAddress = "random";
    ethernet.macAddress = "random";
  };
}
