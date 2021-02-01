{ lib, pkgs, inputs, ... }:

{
  imports = [
    ./boot.nix
    ./builder.nix
    ./software.nix
    ./system.nix
    ./vm.nix

    ../../modules/desktop-env
    ../../modules/console-env.nix
    ../../modules/nix-binary-cache-mirror.nix
    ../../modules/nix-common.nix
    ../../modules/nix-registry.nix
    ../../modules/nixpkgs-allow-unfree-list.nix
    ../../modules/steam-compat.nix
  ] ++ lib.optional (inputs ? secrets) (inputs.secrets + "/nixos-blacksteel.nix");

  networking.hostName = "blacksteel";

  time.timeZone = "Asia/Shanghai";

  users = {
    groups."oxa".gid = 1000;
    users."oxa" = {
      isNormalUser = true;
      uid = 1000;
      group = "oxa";
      extraGroups = [ "wheel" ];
      shell = pkgs.zsh;
    };
  };

  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    users.oxa = import ../../../home/blacksteel.nix;
  };

  # This value determines the NixOS release with which your system is to be
  # compatible, in order to avoid breaking some software such as database
  # servers. You should change this only after NixOS release notes say you
  # should.
  system.stateVersion = "19.09"; # Did you read the comment?
}
