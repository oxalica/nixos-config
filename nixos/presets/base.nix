{ ... }:
{
  users = {
    groups."oxa".gid = 1000;

    users."oxa" = {
      isNormalUser = true;
      uid = 1000;
      group = "oxa";
      extraGroups = [ "wheel" ];
    };
  };

  console.earlySetup = true;

  services.ntp.enable = true;

  # SSD only
  services.fstrim = {
    enable = true;
    interval = "Sat";
  };

  nix.useSandbox = true;

  nix.gc = {
    automatic = true;
    dates = "Wed,Sat";
    options = "--delete-older-than 5d";
  };

  nix.optimise = {
    automatic = true;
    dates = [ "Thu" ];
  };
}
