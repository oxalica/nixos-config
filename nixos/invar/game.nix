{
  lib,
  config,
  pkgs,
  ...
}:
{
  programs.steam.enable = true;

  programs.gamemode = {
    enable = true;
    settings = {
      general = {
        # Will be negated by gamemoded.
        nice = 10;
        igpu_desiredgov = "performance";
        igpu_power_threshold = -1;
      };
      # Check AMD reported performance (CPPC) by:
      # `grep . /sys/devices/system/cpu/cpu*/acpi_cppc/highest_perf | sort --numeric-sort --field-separator=: --key=2 --reverse`
      cpu = {
        pin_cores = "3,5,7";
        park_cores = "11,13,15";
      };
      custom = {
        start = "${lib.getExe pkgs.libnotify} 'Enter GameMode'";
        end = "${lib.getExe pkgs.libnotify} 'Leave GameMode'";
      };
    };
  };

  users.groups."gamemode".members = [ config.users.users.oxa.name ];

  # Additionally delegate cpuset for `AllowedCPUs=`.
  systemd.services."user@" = {
    overrideStrategy = "asDropin";
    serviceConfig.Delegate = "cpuset";
  };

  systemd.user.services."app-steam@" = {
    overrideStrategy = "asDropin";
    serviceConfig = {
      CPUWeight = 200;
      MemorySwapMax = 0;
      MemoryZSwapMax = 0;
      IOWeight = 200;
    };
  };

  systemd.user.services."app-com.obsproject.Studio@" = {
    overrideStrategy = "asDropin";
    serviceConfig = {
      Nice = -1;
      # Avoid colliding CPUs for game.
      AllowedCPUs = "2,4,6,10,12,14";
      MemorySwapMax = 0;
      MemoryZSwapMax = 0;
    };
  };
}
