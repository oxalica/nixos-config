{ pkgs, ... }:
{
  programs.firefox = {
    enable = true;

    # Hardware video decoding support.
    # See: https://wiki.archlinux.org/index.php/Firefox#Hardware_video_acceleration
    package = (pkgs.firefox.override {
      extraPrefs = ''
        pref("gfx.webrender.all", true);
        pref("media.ffmpeg.vaapi.enabled", true);
        pref("media.ffvpx.enabled", false);
        pref("media.rdd-vpx.enabled", false);
        pref("media.navigator.mediadatadecoder_vpx_enabled", true);
        pref("media.av1.enabled", false);
      '';
    }).overrideAttrs (old: {
      buildCommand = old.buildCommand + ''
        sed '/exec /i [[ "$XDG_SESSION_TYPE" == x11 ]] && export MOZ_X11_EGL=1' \
          --in-place "$out/bin/firefox"
      '';
    });
  };

  # Host bridge for `pass` integration.
  programs.browserpass = {
    enable = true;
    browsers = [ "firefox" ];
  };
}
