{ pkgs, ... }:
{
  programs.firefox = {
    enable = true;

    package = (pkgs.firefox.override {
      cfg.enablePlasmaBrowserIntegration = true;
    }).overrideAttrs (old: {
      nativeBuildInputs = old.nativeBuildInputs or [] ++ [ pkgs.zip pkgs.unzip pkgs.breakpointHook ];

      # Hardware video decoding support.
      # See: https://wiki.archlinux.org/index.php/Firefox#Hardware_video_acceleration
      # bash
      buildCommand = old.buildCommand + ''
        sed '/exec /i [[ "$XDG_SESSION_TYPE" == x11 ]] && export MOZ_X11_EGL=1' \
          --in-place "$out/bin/firefox"

        # Rebind C-W to C-S-W for closing tab.
        cd "$(mktemp -d)"
        file="$out/lib/firefox/browser/omni.ja"
        path=chrome/browser/content/browser/browser.xhtml
        unzip "$file"
        sed -E '/id="key_close"/ s/modifiers=".*"/modifiers="accel,shift"/' \
          --in-place "$path"
        # Remove the symlink first.
        rm "$file"
        zip -r "$file" *
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

        "browser.quitShortcut.disabled" = true; # Prevent C-Q to exit browser.
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
