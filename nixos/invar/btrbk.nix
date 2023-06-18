{ ... }:
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
  systemd.services."btrbk-snapshot" = {
    serviceConfig = {
      ProtectSystem = "full";
      ProtectHome = "read-only";
      PrivateNetwork = true;
      IPAddressDeny = "any";
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

        target = "send-receive /mnt/backup/backup-invar";
        target_preserve_min = "1d";
        target_preserve = "7d 4w *m";

        subvolume."home/oxa" = {};
        subvolume."home/oxa/storage" = {};
        subvolume."home/oxa/archive" = {};
      };
    };
  };
  systemd.services."btrbk-backup-wd2t" = {
    unitConfig.RequiresMountsFor = "/mnt/backup";
    serviceConfig = {
      ProtectSystem = "full";
      ProtectHome = "read-only";
      PrivateNetwork = true;
      IPAddressDeny = "any";
    };
  };

  # Mount units for the backup harddisk.
  systemd.mounts = [
    {
      type = "btrfs";
      what = "/dev/disk/by-uuid/25d5061d-ef96-456c-8dd1-1bf650f9152b";
      where = "/mnt/backup";
      requires = [ "systemd-cryptsetup@luksbackup.service" ];
      after = [ "systemd-cryptsetup@luksbackup.service" ];
    }
  ];
  # Dashes inside names seem to be escaped inconsistently.
  environment.etc."crypttab".text = ''
    luksbackup UUID=b300c99f-ca98-4efc-a696-f6e97359bd3c /var/keys/luks-backup-keyfile discard,noauto
  '';
}
