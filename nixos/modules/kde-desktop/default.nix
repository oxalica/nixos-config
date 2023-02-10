{ config, pkgs, ... }:
{
  imports = [ ../l10n.nix ];

  environment.systemPackages = with pkgs.plasma5Packages; [
    ark
    filelight
    plasma-browser-integration
    bismuth
    kwin-dynamic-workspaces
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

    displayManager.sddm.enable = true;
    desktopManager.plasma5 = {
      enable = true;
      useQtScaling = true;
      runUsingSystemd = true;

      # FIXME: remove after https://github.com/NixOS/nixpkgs/pull/215489
      phononBackend = "vlc";

      kdeglobals.KDE.SingleClick = false;
      kwinrc.Windows.RollOverDesktops = true;
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
