{ ... }:
{
  services.btrbk.instances.snapshot = {
    onCalendar = "*:00,30";

    settings = {
      timestamp_format = "long-iso";
      preserve_day_of_week = "monday";
      preserve_hour_of_day = "6";

      snapshot_preserve_min = "6h";
      volume."/" = {
        snapshot_dir = ".snapshots";
        subvolume."home/oxa".snapshot_preserve = "48h 7d";
        subvolume."home/oxa/storage".snapshot_preserve = "48h 7d 4w";
      };
    };
  };
}
