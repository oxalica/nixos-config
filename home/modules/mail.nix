{ pkgs, ... }:
{
  home.packages = with pkgs; [
    hydroxide
    (thunderbird.overrideAttrs (old: {
      # bash
      buildCommand = old.buildCommand + ''
        sed '/exec /i [[ "$XDG_SESSION_TYPE" == wayland ]] && export MOZ_ENABLE_WAYLAND=1' \
          --in-place "$out/bin/thunderbird"
      '';
    }))
  ];

  systemd.user.services."hydroxide" = {
    Unit.Description = "ProtonMail Bridge";
    Service = {
      ExecStart = "${pkgs.hydroxide}/bin/hydroxide serve";
      Restart = "on-failure";
      RestartSec = 10;
      Slice = "background.slice";
    };
    Install.WantedBy = [ "graphical-session.target" ];
  };
}
