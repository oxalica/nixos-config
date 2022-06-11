{ pkgs, ... }:
{
  i18n = {
    supportedLocales = [ "all" ]; # Override console-env.
    defaultLocale = "en_US.UTF-8";
    inputMethod = {
      enabled = "fcitx5";
      fcitx5.addons = with pkgs; [ fcitx5-rime ];
    };
  };

  # Ref: https://catcat.cc/post/2021-03-07/
  fonts = {
    fontDir.enable = true;

    fonts = with pkgs; [
      source-han-sans
      noto-fonts-emoji
      font-awesome
      # Use bin to save build time (~11min).
      (iosevka-bin.override { variant = "sgr-iosevka-fixed"; })
    ];

    fontconfig = {
      enable = true;

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
}
