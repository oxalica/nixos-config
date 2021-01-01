{ pkgs, ... }:

let
  deleteOlderThanDays = "30";

in {
  systemd.user.services."trash-empty" = {
    Unit.Description = "Empty trash older than ${deleteOlderThanDays} days";
    Service.ExecStart = "${pkgs.trash-cli}/bin/trash-empty ${deleteOlderThanDays}";
  };
  systemd.user.timers."trash-empty" = {
    Timer = {
      OnCalendar = "Sat";
      Persistent = true;
    };
    Install.WantedBy = [ "timers.target" ];
  };
}
