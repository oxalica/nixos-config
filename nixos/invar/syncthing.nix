{ config, ... }:
let
  dataDir = config.services.syncthing.dataDir;
in
{
  services.syncthing = {
    enable = true;
    openDefaultPorts = true;
  };

  systemd.mounts = [
    {
      options = "bind,noauto";
      where = "${dataDir}/rubber-photos";
      what = "/home/oxa/storage/5x-state/55-backup/55.04-rubber-photos";
      requiredBy = [ "syncthing.service" ];
      before = [ "syncthing.service" ];
      mountConfig.DirectoryMode = "0000";
    }
    {
      options = "bind,noauto";
      where = "${dataDir}/rubber-seedvault";
      what = "/home/oxa/archive/5x-state/55-backup/55.05-rubber-seedvault";
      requiredBy = [ "syncthing.service" ];
      before = [ "syncthing.service" ];
      mountConfig.DirectoryMode = "0000";
    }
  ];
}
