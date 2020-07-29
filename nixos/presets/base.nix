{ lib, config, ... }:
with lib;
{
  options.oxa-config.preset.base = mkEnableOption "basic system services, and user settings";

  config = mkIf config.oxa-config.preset.base {
    users = {
      groups."oxa".gid = 1000;

      users."oxa" = {
        isNormalUser = true;
        uid = 1000;
        group = "oxa";
        extraGroups = [ "wheel" ];
      };
    };

    # `services.ntp` may block when stopping.
    services.timesyncd.enable = true;

    # SSD only
    services.fstrim = {
      enable = true;
      interval = "Sat";
    };

    nix.useSandbox = true;

    nix.gc = {
      automatic = true;
      dates = "Wed";
      options = "--delete-older-than 7d";
    };

    nix.optimise = {
      automatic = true;
      dates = [ "Thu" ];
    };
  };
}
