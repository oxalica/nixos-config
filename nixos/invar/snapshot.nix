{ lib, config, pkgs, inputs, ... }:
let
  simple-snap = inputs.simple-snap.packages.${pkgs.system}.default;
  exe = lib.getExe simple-snap;
in
{
  systemd.tmpfiles.settings."simple-snap" = {
    "/.snapshots".v = {
      group = config.users.groups.root.name;
      user = config.users.users.root.name;
      mode = "0755";
    };
  };

  systemd.services.simple-snap = {
    description = "Minimalist BTRFS periodic snapshot service";
    after = [ "systemd-tmpfiles-setup.service" ];
    startAt = "*:00/15";

    serviceConfig = {
      Type = "oneshot";
      ExecStart = [
        "${exe} snapshot --target-dir /.snapshots --prefix oxa. --source /home/oxa"
        "${exe} snapshot --target-dir /.snapshots --prefix storage. --source /home/oxa/storage"
        "${exe} snapshot --target-dir /.snapshots --prefix archive. --source /home/oxa/archive"
      ];

      ReadWritePaths = [ "/.snapshots" ];
      CapabilityBoundingSet = [ "CAP_DAC_OVERRIDE" "CAP_FOWNER" ];

      IPAddressDeny = "any";
      LockPersonality = true;
      MemoryDenyWriteExecute = true;
      NoNewPrivileges = true;
      PrivateDevices = true;
      PrivateNetwork = true;
      PrivateTmp = true;
      ProtectClock = true;
      ProtectControlGroups = true;
      ProtectHome = "read-only";
      ProtectHostname = true;
      ProtectKernelLogs = true;
      ProtectKernelModules = true;
      ProtectKernelTunables = true;
      ProtectProc = "noaccess";
      ProtectSystem = "strict";
      RestrictAddressFamilies = "none";
      RestrictNamespaces = true;
      RestrictRealtime = true;
      RestrictSUIDSGID = true;
      SystemCallArchitectures = "native";
      SystemCallFilter = [ "@system-service" "~@privileged" "~@resources" ];
    };
  };

  systemd.services.simple-snap-prune = {
    description = "Minimalist BTRFS periodic snapshot prune service";
    after = [ "systemd-tmpfiles-setup.service" ];
    startAt = "*:50";

    serviceConfig = {
      Type = "oneshot";
      ExecStart = [
        "${exe} prune --target-dir /.snapshots --prefix oxa. --keep-within 6h --keep-hourly 48 --keep-daily 7"
        "${exe} prune --target-dir /.snapshots --prefix storage. --keep-within 6h --keep-hourly 48 --keep-daily 7 --keep-weekly 4"
        "${exe} prune --target-dir /.snapshots --prefix archive. --keep-within 6h --keep-hourly 48 --keep-daily 7 --keep-weekly 4"
      ];

      ReadWritePaths = [ "/.snapshots" ];

      IPAddressDeny = "any";
      LockPersonality = true;
      MemoryDenyWriteExecute = true;
      NoNewPrivileges = true;
      PrivateDevices = true;
      PrivateNetwork = true;
      PrivateTmp = true;
      ProtectClock = true;
      ProtectControlGroups = true;
      ProtectHome = "read-only";
      ProtectHostname = true;
      ProtectKernelLogs = true;
      ProtectKernelModules = true;
      ProtectKernelTunables = true;
      ProtectProc = "noaccess";
      ProtectSystem = "strict";
      RestrictAddressFamilies = "none";
      RestrictNamespaces = true;
      RestrictRealtime = true;
      RestrictSUIDSGID = true;
      SystemCallArchitectures = "native";
      SystemCallFilter = [ "@system-service" "~@privileged" "~@resources" ];
    };
  };
}
