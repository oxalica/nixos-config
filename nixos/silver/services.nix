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

  sops.secrets."ddns_env" = {
    sopsFile = ../../secrets/silver.yaml;
    restartUnits = [ "update-ddns.service" ];
  };
  systemd.services."update-ddns" = {
    description = "Update dynamic DNS record";
    requires = [ "network.target" ];
    after = [ "network.target" ];
    serviceConfig = {
      Type = "oneshot";
      Restart = "on-failure";
      RestartSec = 90;
      SupplementaryGroups = [ config.users.groups.keys.name ];
    };
    path = with pkgs; [ curl dnsutils ];
    script = ''
      set -eo pipefail
      export https_proxy=
      export http_proxy=
      export all_proxy=

      source /run/secrets/ddns_env
      if [[ -z "$DDNS_HOST" || -z "$DDNS_DOMAIN" || -z "$DDNS_KEY" ]]; then
        echo "DDNS environment not set"
        exit 1
      fi
      echo "Updating host=$DDNS_HOST domain=$DDNS_DOMAIN key=<''${#DDNS_KEY}bytes>"

      ip=
      ip="$(curl -sS -4 ifconfig.co)" || true
      echo "Current IP: ''${ip:-(unknown)}"
      old_ip=
      old_ip="$(dig +short "$DDNS_HOST.$DDNS_DOMAIN" A @223.5.5.5)" || true
      echo "Old IP: ''${old_ip:-(unknown)}"

      resp="$(curl -sSL "https://dynamicdns.park-your-domain.com/update?host=$DDNS_HOST&domain=$DDNS_DOMAIN&password=$DDNS_KEY&ip=$ip")"
      if [[ ! "$resp" =~ "<ErrCount>0</ErrCount>" ]]; then
        echo "$resp"
        exit 1
      fi
    '';
  };
  systemd.timers."update-ddns" = {
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnCalendar = "*-*-* *:00/10:00";
      OnBootSec = 30;
    };
  };
}
