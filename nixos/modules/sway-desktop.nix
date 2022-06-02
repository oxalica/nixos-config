{ lib, config, pkgs, ... }:
{
  programs = {
    # Enable zsh related system configurations.
    zsh.enable = true;

    partition-manager.enable = true;
    kdeconnect.enable = true;

    gnupg.agent.pinentryFlavor = "qt";

    dconf.enable = true;

    sway = {
      enable = true;
      extraPackages = with pkgs; [ swayidle swaylock-effects ];
    };
  };

  systemd.services.physlock.enable = true;

  systemd.services.lock-before-suspend = {
    description = "Lock all sessions before suspend";
    partOf = [ "graphical-session.target" ];
    wantedBy = [ "sleep.target" ];
    before = [ "sleep.target" ];
    serviceConfig.ExecStart = "/run/current-system/systemd/bin/loginctl lock-sessions";
  };

  services.logind.extraConfig = ''
    HandlePowerKey=suspend
  '';

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
}
