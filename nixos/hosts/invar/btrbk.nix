{ pkgs, ... }:
{
  environment.systemPackages = [ pkgs.btrbk ];

  # For manual run.
  environment.etc."btrbk/btrbk.conf".source = ./btrbk.conf;

  # Don't check deletion for frequent snapshoting, since it will spin up the target device to check reachable parents.
  systemd.services.btrbk-snapshot-only = {
    description = "btrbk snapshot only";
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${pkgs.btrbk}/bin/btrbk snapshot --preserve default";
    };
  };

  systemd.timers.btrbk-snapshot-only = {
    description = "btrbk snapshot only timer";
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnUnitInactiveSec = "15min";
      OnBootSec = "15min";
    };
  };

  # Snapshot backup and clean up.
  systemd.services.btrbk-backup = {
    description = "btrbk backup and clean up";
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${pkgs.btrbk}/bin/btrbk run default";
    };
  };

  systemd.timers.btrbk-backup = {
    description = "btrbk backup and clean up timer";
    wantedBy = [ "timers.target" ];
    timerConfig.OnCalendar = "03:05:00";
  };
}
