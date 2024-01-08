{ lib, pkgs, my, ... }:
{
  i18n = {
    supportedLocales = [ "all" ]; # Override console-env.
    defaultLocale = "en_CA.UTF-8";
    inputMethod = {
      enabled = "fcitx5";
      fcitx5 = {
        addons = with pkgs; [
          (fcitx5-rime.override {
            rimeDataPkgs = [ rime-data my.pkgs.rime_latex ];
          })
        ];
      };
    };
  };

  # Ref: https://catcat.cc/post/2021-03-07/
  fonts = {
    enableDefaultPackages = false;
    fontDir.enable = true;

    packages = with pkgs; [
      noto-fonts
      noto-fonts-cjk-sans
      noto-fonts-cjk-serif
      noto-fonts-color-emoji
      twemoji-color-font
      font-awesome
      hanazono
      # Use bin to save build time (~11min).
      (iosevka-bin.override { variant = "sgr-iosevka-fixed"; })

      # Roman for PDF.
      liberation_ttf
    ];

    fontconfig = {
      enable = true;

      defaultFonts = {
        monospace = [ "Iosevka Fixed" "Noto Sans CJK SC" "Font Awesome 6 Free" "Twemoji" ];
        sansSerif = [ "Noto Sans" "Noto Sans CJK SC" "Twemoji" ];
        serif = [ "Noto Serif" "Noto Serif CJK SC" "Twemoji" ];
        emoji = [ "Twemoji" ];
      };

      localConf = ''
        <?xml version="1.0" encoding="UTF-8"?>
        <!DOCTYPE fontconfig SYSTEM "urn:fontconfig:fonts.dtd">
        <fontconfig>
          <!-- Use language-specific font variants. -->
          ${lib.concatMapStringsSep "\n" ({ lang, variant }:
            let
              replace = from: to: ''
                <match target="pattern">
                  <test name="lang" compare="contains">
                    <string>${lang}</string>
                  </test>
                  <test name="family">
                    <string>${from}</string>
                  </test>
                  <edit name="family" binding="strong" mode="prepend_first">
                    <string>${to}</string>
                  </edit>
                </match>
              '';
            in
            replace "sans-serif" "Noto Sans CJK ${variant}" +
            replace "serif" "Noto Serif CJK ${variant}"
          ) [
            { lang = "zh";    variant = "SC"; }
            { lang = "zh-TW"; variant = "TC"; }
            { lang = "zh-HK"; variant = "HK"; }
            { lang = "ja";    variant = "JP"; }
            { lang = "ko";    variant = "KR";  }
          ]}
        </fontconfig>
      '';
    };
  };
}
