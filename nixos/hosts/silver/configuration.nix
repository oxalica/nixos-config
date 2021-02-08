{ lib, config, pkgs, inputs, ... }:

{
  imports = [
    ./boot.nix
    ./services.nix

    ../../modules/console-env.nix
    ../../modules/nix-binary-cache-mirror.nix
    ../../modules/nix-common.nix
    ../../modules/nix-registry.nix
  ] ++ lib.optional (inputs ? secrets) (inputs.secrets + "/nixos-silver.nix");

  time.timeZone = "Asia/Shanghai";

  hardware.cpu.intel.updateMicrocode = true;

  environment.systemPackages = with pkgs; [
    screen
  ];

  networking.hostName = "silver";

  # The global useDHCP flag is deprecated, therefore explicitly set to false here.
  networking.useDHCP = false;
  networking.interfaces.enp0s31f6.useDHCP = true;

  users = {
    groups = {
      oxa.gid = 1000;
    };
    users.oxa = {
      isNormalUser = true;
      uid = 1000;
      group = "oxa";
      extraGroups = [ "wheel" ];
    };
  };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "21.03"; # Did you read the comment?
}
