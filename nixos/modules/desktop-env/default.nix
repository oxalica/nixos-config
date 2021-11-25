{ lib, config, pkgs, ... }:
with lib;
{
  environment.systemPackages = with pkgs; [
    ark
    filelight
    plasma-browser-integration
  ];

  programs.partition-manager.enable = true;
  programs.kdeconnect.enable = true;

  nixpkgs.config.firefox.enablePlasmaBrowserIntegration = true;

  services.xserver = {
    enable = true;
    layout = "us";

    displayManager.sddm.enable = true;
    desktopManager.plasma5 = {
      enable = true;
      useQtScaling = true;
      runUsingSystemd = true;
    };
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
    supportedLocales = [ "all" ]; # Override console-env.
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
  };
}
