{ pkgs, ... }:
{
  home.packages = with pkgs; [
    (thunderbird.overrideAttrs (old: {
      # bash
      buildCommand = old.buildCommand + ''
        sed '/exec /i [[ "$XDG_SESSION_TYPE" == wayland ]] && export MOZ_ENABLE_WAYLAND=1' \
          --in-place "$out/bin/thunderbird"
      '';
    }))
  ];
}
