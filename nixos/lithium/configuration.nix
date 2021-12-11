{ inputs, config, pkgs, ... }:
{
  imports = [
    ../modules/vultr-common.nix
    ../modules/console-env.nix
    ../modules/nix-common.nix

    inputs.secrets.nixosModules.lithium
  ];

  environment.systemPackages = with pkgs; [
    wireguard-tools
    git
  ];

  sops.secrets."wgcf-profile.conf".restartUnits = [ "wg-quick-wg0.service" ];
  systemd.services.wg-quick-wg0 = let
    name = "wg0";
    configPath = config.sops.secrets."wgcf-profile.conf".path;
  in {
    description = "wg-quick WireGuard Tunnel - ${name}";
    requires = [ "network-online.target" ];
    after = [ "network.target" "network-online.target" ];
    wantedBy = [ "multi-user.target" ];
    environment.DEVICE = name;
    path = [ pkgs.kmod pkgs.wireguard-tools ];

    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };

    script = ''
      modprobe wireguard
      wg-quick up ${configPath}
    '';

    preStop = ''
      wg-quick down ${configPath}
    '';
  };

  system.stateVersion = "21.11";
}
