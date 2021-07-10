{ lib, config, pkgs, ... }:
with lib;
{
  environment.systemPackages = with pkgs; [
    (ark.override { unfreeEnableUnrar = true; })
    filelight
    kdeconnect
    plasma-browser-integration
    spectacle
  ];

  programs.partition-manager.enable = true;

  nixpkgs.config.firefox.enablePlasmaBrowserIntegration = true;

  # FIXME: For kdeconnect. See https://github.com/NixOS/nixpkgs/pull/63899
  networking.firewall = {
    allowedTCPPortRanges = [{ from = 1714; to = 1764; }];
    allowedUDPPortRanges = [{ from = 1714; to = 1764; }];
  };

  services.xserver = {
    enable = true;
    layout = "us";

    desktopManager.plasma5.enable = true;
    displayManager.sddm.enable = true;
  };

  security.pam.services.sddm.enableKwallet = true;

  fonts = {
    fonts = with pkgs; [ sarasa-gothic emojione ];
    fontDir.enable = true;
    fontconfig.defaultFonts = {
      monospace = [ "Sarasa Mono SC" ];
      sansSerif = [ "Sarasa Gothic SC" ];
      serif = [ "Sarasa Gothic SC" ];
      emoji = [ "EmojiOne Color" ];
    };
  };

  i18n = {
    defaultLocale = "en_US.UTF-8";
    inputMethod = {
      enabled = "fcitx5";
      fcitx5.addons = with pkgs; [ fcitx5-rime ];
    };
  };

  networking.networkmanager = {
    enable = true;
    wifi.macAddress = "random";
    ethernet.macAddress = "random";
  };

  environment.etc = {
    "xdg/kdeglobals".source = ./xdg/kdeglobals;
    "xdg/kglobalshortcutsrc".source = ./xdg/kglobalshortcutsrc;
    "xdg/kwinrc".source = ./xdg/kwinrc;
    "xdg/kwinrulesrc".source = ./xdg/kwinrulesrc;
    "xdg/spectaclerc".source = ./xdg/spectaclerc;
    "xdg/startkderc".source = ./xdg/startkderc;
  };
}
