{ ... }:
{
  services.orb.instances.main.settings = {
    ublk.id = 80;
    device = {
      dev_size = "1TiB";
      zone_size = "256MiB";
      min_chunk_size = "1MiB";
      max_chunk_size = "256MiB";
      max_concurrent_streams = 16;
      max_concurrent_commits = 4; # 1GiB buffers.
    };
    backend.onedrive.remote_dir = "/orb";
  };

  environment.etc."crypttab".text = ''
    orb-main /dev/ublkb80 /var/keys/orb-main-keyfile noauto
  '';
  systemd.services."systemd-cryptsetup@orb\\x2dmain" = {
    overrideStrategy = "asDropin";
    # No way to continue if the service is dead somehow.
    bindsTo = [ "orb@main.service" ];
    after = [ "orb@main.service" ];
  };
  systemd.mounts = [
    {
      type = "btrfs";
      what = "/dev/disk/by-uuid/0f880b1f-3fd6-4aac-a29e-959e6f07ed81";
      where = "/mnt/orb-main";
      requires = [ "systemd-cryptsetup@orb\\x2dmain.service" ];
      after = [ "systemd-cryptsetup@orb\\x2dmain.service" ];
      options = "noatime,commit=300,compress=zstd:7";
    }
  ];
}
