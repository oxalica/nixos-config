{ lib, config, pkgs, ... }:
with lib;
let cfg = options.oxa-config; in
{
  options.oxa-config = {
    preset.desktop-kde = mkEnableOption "KDE desktop environment";
    ark.unfreeEnableUnrar = mkEnableOption "unrar support in ark";
    dpi = mkOption {
      type = with types; nullOf int;
      description = "monitor DPI for X server";
      default = null;
      example = 144;
    };
  };

  config = mkIf cfg.preset.desktop-kde {
    environment.systemPackages = with pkgs; [
      partition-manager
      spectacle
      plasma-browser-integration
      (ark.override { inherit (cfg.ark) unfreeEnableUnrar; })
    ];

    services.xserver = {
      enable = true;
      layout = "us";
      inherit (cfg) dpi;

      desktopManager.plasma5.enable = true;
      displayManager.sddm.enable = true;
    };

    security.pam.services.sddm.enableKwallet = true;

    fonts = {
      fonts = with pkgs; [ sarasa-gothic emojione ];
      enableFontDir = true;
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

    boot.kernel.sysctl."kernel.sysrq" = "1";

    services.earlyoom = {
      enable = true;
      freeMemThreshold = 5;
      freeSwapThreshold = 10;
      enableNotifications = true;
    };
  };
}
