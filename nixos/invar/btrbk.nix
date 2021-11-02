{ pkgs, ... }:
{
  environment.systemPackages = [ pkgs.btrbk ];

  # For manual run.
  environment.etc."btrbk/btrbk.conf".source = ./btrbk.conf;

  systemd.services.btrbk-snapshot = {
    description = "btrbk snapshot";
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${pkgs.btrbk}/bin/btrbk run snapshot";
    };
  };

  systemd.timers.btrbk-snapshot = {
    description = "btrbk snapshot timer";
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnUnitInactiveSec = "15min";
      OnBootSec = "15min";
    };
  };

  systemd.services.btrbk-backup-wd2t = {
    description = "btrbk backup wd2t";
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${pkgs.btrbk}/bin/btrbk run --progress wd2t";
    };
  };

  systemd.timers.btrbk-backup-wd2t = {
    description = "btrbk backup wd2t timer";
    wantedBy = [ "timers.target" ];
    timerConfig.OnCalendar = "03:05:00";
  };
}
