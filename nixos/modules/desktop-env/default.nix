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

  # Ref: https://catcat.cc/post/2021-03-07/
  fonts = {
    fontDir.enable = true;

    fonts = with pkgs; [
      source-han-sans
      noto-fonts-emoji
      # twemoji-color-font
      (iosevka-bin.override { variant = "sgr-iosevka-fixed"; }) # Use bin to save build time (~10min).
    ];

    fontconfig = {
      enable = true;

      subpixel.rgba = "none"; # Every device uses LCD now.

      defaultFonts = rec {
        monospace = [ "Iosevka Fixed" "Source Han Sans SC" "Noto Color Emoji" ];
        sansSerif = [ "Source Han Sans SC" "Noto Color Emoji" ];
        serif = sansSerif;
        emoji = [ "Noto Color Emoji" ];
      };

      localConf = let
        rewriteLang = lang: variant: ''
          <match target="pattern">
            <test name="lang">
              <string>${lang}</string>
            </test>
            <test name="family">
              <string>Source Han Sans SC</string>
            </test>
            <edit name="family" binding="strong">
              <string>Source Han Sans ${variant}</string>
            </edit>
          </match>
        '';
      in ''
        <?xml version="1.0" encoding="UTF-8"?>
        <!DOCTYPE fontconfig SYSTEM "urn:fontconfig:fonts.dtd">
        <fontconfig>
          ${rewriteLang "zh-TW" "TC"}
          ${rewriteLang "zh-HK" "HC"}
          ${rewriteLang "ja" "JP"}
          ${rewriteLang "ko" "K"}
        </fontconfig>
      '';
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
