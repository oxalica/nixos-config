{ pkgs, ... }:
{
  programs.firefox = {
    enable = true;

    package = pkgs.firefox.overrideAttrs (old: {
      nativeBuildInputs = old.nativeBuildInputs or [] ++ [ pkgs.zip pkgs.unzip ];

      # bash
      buildCommand = old.buildCommand + ''
        sed '/exec /i [[ "$XDG_SESSION_TYPE" == wayland ]] && export MOZ_ENABLE_WAYLAND=1' \
          --in-place "$out/bin/firefox"

        # Rebind C-W to C-S-W for closing tab.
        from1='<key id="key_close" data-l10n-id="close-shortcut" command="cmd_close" modifiers="accel" reserved="true"/>'
        to__1='<key id="key_close" data-l10n-id="close-shortcut" command="cmd_close" modifiers="accel,shift" reserved="true"/>'
        from2='<key id="key_closeWindow" data-l10n-id="close-shortcut" command="cmd_closeWindow" modifiers="accel,shift" reserved="true"/>'
        to__2='                                                                                                                     '
        file="$out/lib/firefox/browser/omni.ja"
        # The original file is a symlink.
        sed -E "s|$from1|$to__1|; s|$from2|$to__2|" "$file" >"$file.new"
        size1="$(stat -L -c '%s' "$file")"
        size2="$(stat -L -c '%s' "$file.new")"
        echo "$size1 $size2"
        [[ $size1 -eq $size2 ]]
        mv "$file.new" "$file"
      '';
    });

    profiles."main.profile" = {
      id = 0;
      isDefault = true;

      settings = {
        # Random config
        "browser.aboutConfig.showWarning" = false;
        "browser.toolbars.bookmarks.visibility" = "newtab";
        "browser.quitShortcut.disabled" = true; # Prevent C-Q to exit browser.

        # Theme.
        "devtools.theme" = "auto";
        "extensions.activeThemeID" = "efault-theme@mozilla.org";
        "browser.display.use_system_colors" = true;

        # Let our font-config choose final fonts.
        "font.language.group" = "zh-CN";
        "font.name.monospace.zh-CN" = "monospace";
        "font.name.sans-serif.zh-CN" = "sans-serif";
        "font.name.serif.zh-CN" = "serif";

        # Hardware video decoding support.
        # See: https://wiki.archlinux.org/index.php/Firefox#Hardware_video_acceleration
        "gfx.webrender.all" = true;
        "media.ffmpeg.vaapi.enabled" = true;

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

  # https://bugzilla.mozilla.org/show_bug.cgi?id=1699942
  home.packages = [ pkgs.arc-theme ];
}
