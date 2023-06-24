{ pkgs, ... }:
{
  imports = [ ../l10n.nix ];

  environment.systemPackages = with pkgs.plasma5Packages; [
    ark
    filelight
    plasma-browser-integration
    bismuth
  ];

  programs = {
    partition-manager.enable = true;
    kdeconnect.enable = true;
    dconf.enable = true;
  };

  nixpkgs.config.firefox.enablePlasmaBrowserIntegration = true;

  services.xserver = {
    enable = true;
    layout = "us";

    displayManager = {
      defaultSession = "plasmawayland";
      sddm.enable = true;
      # Ref: https://wiki.archlinux.org/title/SDDM#KDE_/_KWin
      sddm.settings = {
        General.GreeterEnvironment = "QT_WAYLAND_SHELL_INTEGRATION=layer-shell";
        General.DisplayServer = "wayland";
        General.InputMethod = "";
        Wayland.CompositorCommand = "${pkgs.kwin}/bin/kwin_wayland --no-global-shortcuts --no-lockscreen --inputmethod maliit-keyboard --locale1";
      };
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
