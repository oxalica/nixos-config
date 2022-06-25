{ pkgs, ... }:
let
  globalSettings = {
    timestamp_format = "long-iso";
    preserve_day_of_week = "monday";
    preserve_hour_of_day = "6";
  };

in
{
  # 15min snapshot.
  services.btrbk.instances.snapshot = {
    onCalendar = "*:00/15";
    settings = globalSettings // {
      volume."/" = {
        snapshot_dir = ".btrbk/snapshot";
        snapshot_create = "onchange";
        snapshot_preserve_min = "6h";

        subvolume."home/oxa".snapshot_preserve = "48h 7d";
        subvolume."home/oxa/storage".snapshot_preserve = "48h 7d 4w";
        subvolume."home/oxa/archive".snapshot_preserve = "48h 7d 4w";
      };
    };
  };

  # Manual backup.
  services.btrbk.instances.backup-wd2t = {
    onCalendar = null;
    settings = globalSettings // {
      volume."/" = {
        snapshot_dir = ".btrbk/backup-wd2t";
        snapshot_create = "ondemand"; # Always create.
        snapshot_preserve_min = "latest";

        target = "send-receive /run/media/oxa/WD2T-external-store/backup-invar";
        target_preserve_min = "1d";
        target_preserve = "7d 4w *m";

        subvolume."home/oxa" = {};
        subvolume."home/oxa/storage" = {};
        subvolume."home/oxa/archive" = {};
      };
    };
  };
}
