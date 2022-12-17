{ lib, config, pkgs, ... }:
{
  networking.firewall = {
    enable = true;
    allowedTCPPorts = [ 23333 23334 23335 23336 ];
  };

  services.openssh = {
    enable = true;
    ports = [ 23333 ];
    passwordAuthentication = false;
    extraConfig = ''
      ClientAliveInterval 70
      ClientAliveCountMax 3
    '';
  };

  sops.secrets.reverse-ssh-host.restartUnits = [ "reverse-ssh.service" ];
  systemd.services."reverse-ssh" = {
    wants = [ "network-online.target" ];
    after = [ "network-online.target" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Type = "simple";
      Restart = "always";
      RestartSec = 60;
      SupplementaryGroups = [ config.users.groups.keys.name ];
    };
    path = [ pkgs.openssh ];
    script = ''
      ssh -N -R 2222:localhost:${toString (lib.head config.services.openssh.ports)} \
        -o ServerAliveInterval=60 \
        -o ServerAliveCountMax=3 \
        -o StrictHostKeyChecking=yes \
        -o IdentityFile=/etc/ssh/ssh_host_ed25519_key \
        "$(cat ${config.sops.secrets.reverse-ssh-host.path})"
    '';
  };
}
