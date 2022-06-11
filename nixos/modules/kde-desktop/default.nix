{ lib, config, pkgs, ... }:
with lib;
{
  environment.systemPackages = with pkgs; [
    ark
    filelight
    plasma-browser-integration
  ];

  # Enable zsh related system configurations.
  # This is required for sddm to source /etc/set-environment in login script.
  programs.zsh.enable = true;

  programs.partition-manager.enable = true;
  programs.kdeconnect.enable = true;

  programs.gnupg.agent.pinentryFlavor = "qt";

  programs.dconf.enable = true;

  nixpkgs.config.firefox.enablePlasmaBrowserIntegration = true;

  services.xserver = {
    enable = true;
    layout = "us";

    displayManager.sddm.enable = true;
    desktopManager.plasma5 = {
      enable = true;
      useQtScaling = true;
      runUsingSystemd = true;

      kdeglobals.KDE.SingleClick = false;
      kwinrc = {
        Desktops.Number = 3;
        Desktops.Rows = 1;
        Windows.RollOverDesktops = true;
      };
    };
  };

  security.pam.services.sddm.enableKwallet = true;

  networking.networkmanager = {
    enable = true;
    wifi.macAddress = "random";
    ethernet.macAddress = "random";
  };

  environment.etc = {
    "xdg/kglobalshortcutsrc".source = ./xdg/kglobalshortcutsrc;
  };
}
