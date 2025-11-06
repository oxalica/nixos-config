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
    enableRenice = true;
    settings = {
      # Will be negated by gamemoded.
      general.renice = 10;

      # Check AMD reported performance (CPPC) by:
      # `grep . /sys/devices/system/cpu/cpu*/acpi_cppc/highest_perf | sort --numeric-sort --field-separator=: --key=2 --reverse`
      cpu.pin_cores = "3-7,11-15";
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

  systemd.user.services."app-org.prismlauncher.PrismLauncher@" = {
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
      AllowedCPUs = "0-2,8-10";
      MemorySwapMax = 0;
      MemoryZSwapMax = 0;
    };
  };
}
