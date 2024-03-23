{ pkgs, inputs, ... }:
let
  inherit (inputs.orb.packages.${pkgs.system}) orb;
  inherit (inputs.self.lib) toTOML;

  orbConfig = {
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

in {
  systemd.packages = [ orb ];
  environment.systemPackages = [ orb ];

  # Do not accidentally stop active filesystems.
  systemd.services."orb@" = {
    restartIfChanged = false;
    stopIfChanged = false;
  };

  environment.etc."orb/main.toml".text = toTOML orbConfig;

  # Escaping of `-` is problematic.
  environment.etc."crypttab".text = ''
    orbmain /dev/ublkb80 /var/keys/invar-orb-main-keyfile discard,noauto
  '';
  systemd.services."systemd-cryptsetup@orbmain" = {
    overrideStrategy = "asDropin";
    bindsTo = [ "orb@main.service" ];
    after = [ "orb@main.service" ];
  };
  systemd.mounts = [
    {
      type = "btrfs";
      what = "/dev/disk/by-uuid/0f880b1f-3fd6-4aac-a29e-959e6f07ed81";
      where = "/mnt/orbmain";
      bindsTo = [ "systemd-cryptsetup@orbmain.service" ];
      after = [ "systemd-cryptsetup@orbmain.service" ];
      options = "noatime,commit=300,compress=zstd:7";
    }
  ];
}
