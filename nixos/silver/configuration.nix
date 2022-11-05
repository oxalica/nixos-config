{ lib, config, pkgs, inputs, ... }:

{
  imports = [
    ./boot.nix
    ./services.nix

    ../modules/console-env.nix
    ../modules/nix-binary-cache-mirror.nix
    ../modules/nix-common.nix
  ] ++ lib.optional (inputs ? secrets) (inputs.secrets.nixosModules.silver);

  sops.secrets.passwd.neededForUsers = true;
  users = {
    mutableUsers = false;
    users."oxa" = {
      isNormalUser = true;
      passwordFile = config.sops.secrets.passwd.path;
      uid = 1000;
      group = config.users.groups.oxa.name;
      extraGroups = [ "wheel" ];
    };
    groups."oxa".gid = 1000;
  };

  time.timeZone = "Asia/Shanghai";

  hardware.cpu.intel.updateMicrocode = true;

  networking.hostName = "silver";

  # The global useDHCP flag is deprecated, therefore explicitly set to false here.
  networking.useDHCP = false;
  networking.interfaces.enp0s31f6.useDHCP = true;

  security.sudo.wheelNeedsPassword = false;

  system.stateVersion = "21.11";
}
