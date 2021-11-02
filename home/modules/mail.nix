{ pkgs, ... }:
{
  home.packages = with pkgs; [
    hydroxide
    birdtray
    # birdtray runs `~/.nix-profile/bin/thunderbird`
    (thunderbird.overrideAttrs (old: {
      # bash
      buildCommand = old.buildCommand + ''
        sed '/exec /i [[ "$XDG_SESSION_TYPE" == wayland ]] && export MOZ_ENABLE_WAYLAND=1' \
          --in-place "$out/bin/thunderbird"
      '';
    }))
  ];

  xdg.configFile."autostart/birdtray.desktop".source =
    "${pkgs.birdtray}/share/applications/com.ulduzsoft.Birdtray.desktop";
}
