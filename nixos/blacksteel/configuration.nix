{ lib, config, pkgs, inputs, ... }:

{
  imports = [
    ./boot.nix
    ./btrbk.nix
    ./builder.nix
    ./software.nix
    ./system.nix
    ./vm.nix

    ../modules/console-env.nix
    ../modules/desktop-env
    ../modules/nix-binary-cache-mirror.nix
    ../modules/nix-common.nix
    ../modules/nix-registry.nix
    ../modules/nixpkgs-allow-unfree-list.nix
    ../modules/steam-compat.nix
    ../modules/user-oxa.nix
  ] ++ lib.optional (inputs ? secrets) (inputs.secrets.nixosModules.blacksteel);

  networking.hostName = "blacksteel";

  time.timeZone = "Asia/Bangkok";

  sops.secrets.passwd.neededForUsers = true;
  users.users."oxa" = {
    shell = pkgs.zsh;
    passwordFile = config.sops.secrets.passwd.path;
  };

  home-manager.users."oxa" = import ../../home/blacksteel.nix;

  # This value determines the NixOS release with which your system is to be
  # compatible, in order to avoid breaking some software such as database
  # servers. You should change this only after NixOS release notes say you
  # should.
  system.stateVersion = "21.11"; # Did you read the comment?
}
