{ lib, pkgs, ... }:
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
    enableDefaultFonts = false;
    fontDir.enable = true;

    fonts = with pkgs; [
      noto-fonts
      noto-fonts-cjk-sans
      noto-fonts-cjk-serif
      noto-fonts-emoji
      twemoji-color-font
      font-awesome
      # Use bin to save build time (~11min).
      (iosevka-bin.override { variant = "sgr-iosevka-fixed"; })
    ];

    fontconfig = {
      enable = true;

      defaultFonts = rec {
        monospace = [ "Iosevka Fixed" "Noto Sans CJK SC" "Font Awesome 6 Free" "Twemoji" ];
        # Prefer CJK-SC-style quotation marks.
        # We cannot select different styles for it based on languages since our locale is en_US.UTF-8.
        # See: https://catcat.cc/post/2021-03-07/#remark42__comment-37ccca1d-cbc6-4c48-a224-18007987cf16
        sansSerif = [ "Noto Sans CJK SC" "Noto Sans" "Twemoji" ];
        serif = [ "Noto Serif CJK SC" "Noto Serif" "Twemoji" ];
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
                  <test name="lang">
                    <string>${lang}</string>
                  </test>
                  <test name="family">
                    <string>${from}</string>
                  </test>
                  <edit name="family" binding="strong">
                    <string>${to}</string>
                  </edit>
                </match>
              '';
            in
            replace "Noto Sans CJK SC" "Noto Sans CJK ${variant}" +
            replace "Noto Serif CJK SC" "Noto Serif CJK ${variant}"
          ) [
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
