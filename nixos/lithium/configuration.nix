{ config, pkgs, inputs, my, ... }:
{
  imports = [
    ../modules/console-env.nix
    ../modules/nix-common.nix
    ../modules/vultr-common.nix

    inputs.secrets.nixosModules.lithium
  ];

  documentation.enable = false;

  swapDevices = [
    {
      device = "/var/swapfile";
      size = 1024;
    }
  ];

  environment.systemPackages = with pkgs; [
    git
  ];

  sops.secrets."cloudflare/privateKey".restartUnits = [ "wireguard-cloudflare.service" ];
  networking.wireguard.interfaces = {
    cloudflare = {
      privateKeyFile = config.sops.secrets."cloudflare/privateKey".path;
      ips = [
        "172.16.0.2/32"
        "fd01:5ca1:ab1e:86e9:be58:3c01:90c4:5a7d/128"
      ];
      peers = [
        {
          allowedIPs = [ "0.0.0.0/0" ];
          endpoint = "engage.cloudflareclient.com:2408";
          publicKey = "bmXOC+F1FxEMF9dyiK2H5/1SUtzH0JuVo51h2wPfgyo=";
        }
      ];
    };
  };

  users.groups."reverse-ssh" = {};
  users.users."reverse-ssh" = {
    isSystemUser = true;
    shell = pkgs.shadow;
    group = config.users.groups.reverse-ssh.name;
    openssh.authorizedKeys.keys = [
      my.ssh.identities.silver
    ];
  };

  system.stateVersion = "22.11";
}
