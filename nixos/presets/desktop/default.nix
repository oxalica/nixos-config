{ lib, pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    partition-manager
    spectacle
    plasma-browser-integration
    (ark.override { unfreeEnableUnrar = true; })
  ];
  nixpkgs.config.allowUnfree = true;

  services.xserver = {
    enable = true;
    layout = "us";

    desktopManager.plasma5.enable = true;
    displayManager.sddm.enable = true;
  };

  security.pam.services.sddm.enableKwallet = true;

  environment.etc = lib.mapAttrs' (name: type: {
    name = "xdg/${name}";
    value.source = "${./xdg}/${name}";
  }) (builtins.readDir ./xdg);

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

  services.earlyoom = {
    enable = true;
    freeMemThreshold = 5;
    freeSwapThreshold = 10;
    enableNotifications = true;
  };
}
