{ lib, config, pkgs, ... }:
with lib;
{
  environment.systemPackages = with pkgs; [
    (ark.override { unfreeEnableUnrar = true; })
    filelight
    kdeconnect
    partition-manager
    plasma-browser-integration
    spectacle
  ];

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
      sansSerif = [ "Sarasa UI SC" ];
      serif = [ "Sarasa UI SC" ];
      emoji = [ "EmojiOne Color" ];
    };
  };

  i18n = {
    defaultLocale = "en_US.UTF-8";
    inputMethod = {
      enabled = "fcitx";
      fcitx.engines = with pkgs.fcitx-engines; [ rime ];
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
  };
}
