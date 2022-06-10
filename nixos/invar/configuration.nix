{ lib, config, pkgs, inputs, ... }:

{
  imports = [
    ./boot.nix
    ./btrbk.nix
    ./software.nix
    ./system.nix

    ../modules/console-env.nix
    ../modules/sway-desktop.nix
    ../modules/nix-binary-cache-mirror.nix
    ../modules/nix-common.nix
    ../modules/nix-registry.nix
    ../modules/nixpkgs-allow-unfree-list.nix
    ../modules/steam-compat.nix
    ../modules/user-oxa.nix
  ] ++ lib.optional (inputs ? secrets) inputs.secrets.nixosModules.invar;

  sops.age.sshKeyPaths = lib.mkForce [ "/var/ssh/ssh_host_ed25519_key" ];

  nix.extraOptions = ''
    experimental-features = nix-command flakes ca-derivations
  '';

  networking = {
    hostName = "invar";
    search = [ "lan." ];
    useNetworkd = true;
    useDHCP = false;
    interfaces = {
      enp10s0.useDHCP = true;
      wlp9s0.useDHCP = true;
    };
    wireless = {
      enable = true;
      userControlled.enable = true;
    };
  };
  systemd.network.wait-online = {
    anyInterface = true;
    timeout = 15;
  };

  time.timeZone = "Asia/Shanghai";

  sops.secrets.passwd.neededForUsers = true;
  users = {
    mutableUsers = false;
    users."oxa" = {
      shell = pkgs.zsh;
      passwordFile = config.sops.secrets.passwd.path;
    };
  };

  home-manager.users."oxa" = import ../../home/invar.nix;

  services.logind.extraConfig = ''
    HandlePowerKey=suspend
  '';

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "21.11"; # Did you read the comment?

}
