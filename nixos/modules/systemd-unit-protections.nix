{ ... }:
{
  systemd.services = {
    earlyoom.serviceConfig = {
      # Upstream rules.
      DynamicUser = true;
      AmbientCapabilities = "CAP_KILL CAP_IPC_LOCK";
      Nice = -20;
      OOMScoreAdjust = -100;
      ProtectSystem = "strict";
      ProtectHome = true;
      Restart = "always";
      TasksMax = 10;
      MemoryMax = "50M";

      # Protection rules. Mostly copied from systemd-oomd.service, with some
      # already included upstream.
      CapabilityBoundingSet = "CAP_KILL CAP_IPC_LOCK";
      PrivateDevices = true;
      ProtectClock = true;
      ProtectHostname = true;
      ProtectKernelLogs = true;
      ProtectKernelModules = true;
      ProtectKernelTunables = true;
      ProtectControlGroups = true;
      RestrictNamespaces = true;
      RestrictRealtime = true;

      PrivateNetwork = true;
      IPAddressDeny = "any";
      RestrictAddressFamilies = "AF_UNIX";

      SystemCallArchitectures = "native";
      SystemCallFilter = [ "@system-service" "~@resources @privileged" ];
    };
  };
}
