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
    challengeResponseAuthentication = false;
    extraConfig = ''
      ClientAliveInterval 70
      ClientAliveCountMax 3
    '';
  };

  virtualisation.libvirtd = {
    enable = true;
    onBoot = "ignore";
  };
  boot.kernel.sysctl."net.ipv4.ip_forward" = 1;
  users.groups."libvirtd".members = [ "oxa" ];

  environment.systemPackages = [ pkgs.qemu ];

  sops.secrets.ddclient-password.restartUnits = [ "ddclient.service" ];
  services.ddclient = {
    enable = true;
    interval = "10min";
    ipv6 = false;
    ssl = true;
    use = "web, web=dynamicdns.park-your-domain.com/getip";
    server = "dynamicdns.park-your-domain.com";
    passwordFile = config.sops.secrets.ddclient-password.path;
  };
}
