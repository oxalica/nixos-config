{ pkgs, ... }:
{
  programs.firefox = {
    enable = true;

    package = (pkgs.firefox.override {
      cfg.enablePlasmaBrowserIntegration = true;
    }).overrideAttrs (old: {
      # Hardware video decoding support.
      # See: https://wiki.archlinux.org/index.php/Firefox#Hardware_video_acceleration
      buildCommand = old.buildCommand + ''
        sed '/exec /i [[ "$XDG_SESSION_TYPE" == x11 ]] && export MOZ_X11_EGL=1' \
          --in-place "$out/bin/firefox"
      '';
    });

    profiles."main.profile" = {
      id = 0;
      isDefault = true;

      settings = {
        # Random config
        "ui.systemUsesDarkTheme" = true;
        "browser.aboutConfig.showWarning" = false;
        "browser.toolbars.bookmarks.visibility" = "always";

        # Let our font-config choose final fonts.
        "font.language.group" = "zh-CN";
        "font.name.monospace.zh-CN" = "monospace";
        "font.name.sans-serif.zh-CN" = "sans-serif";
        "font.name.serif.zh-CN" = "serif";

        # Hardware video decoding support.
        # See: https://wiki.archlinux.org/index.php/Firefox#Hardware_video_acceleration
        "gfx.webrender.all" = true;
        "media.ffmpeg.vaapi.enabled" = true;
        "media.ffvpx.enabled" = false;
        "media.rdd-vpx.enabled" = false;
        "media.navigator.mediadatadecoder_vpx_enabled" = true;
        "media.av1.enabled" = false; # My GPU doesn't support this.

        # Enable user chrome, which is by default disabled.
        "toolkit.legacyUserProfileCustomizations.stylesheets" = true;

        # Site isolation.
        "fission.autostart" = true;
      };

      # Hide tab
      userChrome = ''
        #main-window[tabsintitlebar="true"]:not([extradragspace="true"]) #TabsToolbar > .toolbar-items {
          opacity: 0;
          pointer-events: none;
        }
        #main-window:not([tabsintitlebar="true"]) #TabsToolbar {
          visibility: collapse !important;
        }
      '';
    };

    # For test.
    profiles."test.profile" = {
      id = 1;
      isDefault = false;
    };
  };

  # Host bridge for `pass` integration.
  programs.browserpass = {
    enable = true;
    browsers = [ "firefox" ];
  };
}
