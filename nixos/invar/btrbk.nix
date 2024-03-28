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

        target = "send-receive /mnt/wd2t-btrfs/backup-invar";
        target_preserve_min = "1d";
        target_preserve = "7d 4w *m";

        subvolume."home/oxa" = {};
        subvolume."home/oxa/storage" = {};
        subvolume."home/oxa/archive" = {};
      };
    };
  };

  # Backup on harddisk wd2t-btrfs.
  systemd.services."btrbk-backup-wd2t" = {
    unitConfig = {
      RequiresMountsFor = "/mnt/wd2t-btrfs/backup-invar";
      PropagatesStopTo = [ "systemd-cryptsetup@wd2t\\x2dbtrfs.service" ];
    };
    serviceConfig = {
      ProtectSystem = "full";
      ProtectHome = "read-only";
      PrivateNetwork = true;
      IPAddressDeny = "any";
    };
  };
  systemd.mounts = [
    {
      type = "btrfs";
      what = "/dev/disk/by-uuid/25d5061d-ef96-456c-8dd1-1bf650f9152b";
      where = "/mnt/wd2t-btrfs";
      requires = [ "systemd-cryptsetup@wd2t\\x2dbtrfs.service" ];
      after = [ "systemd-cryptsetup@wd2t\\x2dbtrfs.service" ];
    }
  ];
  environment.etc."crypttab".text = ''
    wd2t-btrfs UUID=b300c99f-ca98-4efc-a696-f6e97359bd3c /var/keys/wd2t-btrfs-keyfile discard,noauto
  '';

  # Cloud backup.
  services.btrbk.instances.backup-orb = {
    onCalendar = null;
    settings = globalSettings // {
      volume."/" = {
        snapshot_dir = ".btrbk/backup-orb";
        snapshot_create = "ondemand"; # Always create.
        snapshot_preserve_min = "latest";

        target = "send-receive /mnt/orb-main/backup-invar";
        target_preserve_min = "1w";
        target_preserve = "*w";

        subvolume."home/oxa/storage" = {};
        subvolume."home/oxa/archive" = {};
      };
    };
  };
  systemd.services."btrbk-backup-orb" = {
    unitConfig = {
      PropagatesStopTo = [ "orb@main.service" ]; # Stop orb when done.
      RequiresMountsFor = "/mnt/orb-main/backup-invar";
    };
    serviceConfig = {
      ProtectSystem = "full";
      ProtectHome = "read-only";
      PrivateNetwork = true;
      IPAddressDeny = "any";
    };
  };
}
