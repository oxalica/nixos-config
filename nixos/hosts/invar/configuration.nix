{ lib, config, pkgs, inputs, ... }:

{
  imports = [
    ./boot.nix
    ./btrbk.nix
    ./software.nix
    ./system.nix

    ../../modules/console-env.nix
    ../../modules/desktop-env
    ../../modules/nix-binary-cache-mirror.nix
    ../../modules/nix-common.nix
    ../../modules/nix-registry.nix
    ../../modules/nixpkgs-allow-unfree-list.nix
    ../../modules/steam-compat.nix
  ] ++ lib.optional (inputs ? secrets) (inputs.secrets + "/nixos-invar.nix");

  systemd.user.services.fcitx5-daemon.enable = lib.mkForce false;

  networking.hostName = "invar";

  time.timeZone = "Asia/Shanghai";

  users = {
    mutableUsers = false;
    groups."oxa".gid = 1000;
    users."oxa" = {
      isNormalUser = true;
      uid = 1000;
      group = "oxa";
      extraGroups = [ "wheel" ];
      shell = pkgs.zsh;
    } // (if inputs ? secrets then {
      initialHashedPassword = (import (inputs.secrets + "/passwd.nix")).oxa;
    } else {
      initialPassword = "oxa";
    });

    users."root" = if inputs ? secrets then {
      initialHashedPassword = (import (inputs.secrets + "/passwd.nix")).root;
    } else {
      initialPassword = "root";
    };
  };

  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    users.oxa = import ../../../home/invar.nix;
  };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "21.11"; # Did you read the comment?

}
