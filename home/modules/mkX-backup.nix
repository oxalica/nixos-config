{ pkgs, ... }:

{
  systemd.user.services."mkX-backup" = {
    Unit = {
      Description = "mkX world backup using rsync";
      StartLimitIntervalSec = 3600;
      StartLimitBurst = 5;
    };
    Service = {
      Environment = "PATH=${pkgs.openssh}/bin";
      ExecStart = "${pkgs.rsync}/bin/rsync -av --ignore-existing hex0:/Plain/Games/mcservers/mkX/backups/ /home/oxa/Downloads/mkX/";
      Restart = "on-failure";
      RestartSec = 300;
    };
  };

  systemd.user.timers."mkX-backup" = {
    Timer = {
      OnCalendar = "*-*-* 12:00:00";
      Persistent = true;
    };
    Install.WantedBy = [ "timers.target" ];
  };
}
