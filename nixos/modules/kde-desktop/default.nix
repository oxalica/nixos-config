{ config, pkgs, ... }:
{
  imports = [ ../l10n.nix ];

  environment.systemPackages = with pkgs; [
    ark
    filelight
    plasma-browser-integration
  ];

  programs = {
    partition-manager.enable = true;
    kdeconnect.enable = true;
    gnupg.agent.pinentryFlavor = "qt";
    dconf.enable = true;
  };

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
