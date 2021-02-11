{ lib, pkgs, inputs, ... }:
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

  systemd.services."update-ddns" = {
    description = "Update dynamic DNS record";
    requires = [ "network.target" ];
    after = [ "network.target" ];
    serviceConfig = {
      Type = "oneshot";
      Restart = "on-failure";
      RestartSec = 61;
    };
    startLimitIntervalSec = 60;
    startLimitBurst = 1;
    path = with pkgs; [ curl dnsutils ];
    script = ''
      set -eo pipefail
      export https_proxy=
      export all_proxy=

      host="$1"
      domain="$2"
      key="$3"

      ip="$(curl -sSL "https://api-ipv4.ip.sb/ip")"
      echo "Current IP: $ip"
      old_ip=
      old_ip="$(dig "$host.$domain" A @8.8.8.8 | sed -nE 's/^[^;].*\sA\s*(\S+)$/\1/p')" || true
      echo "Old IP: ''${old_ip:-(unknown)}"
      if [[ "$ip" == "$old_ip" ]]; then
        echo "Identical"
        exit
      fi

      resp="$(curl -sSL "https://dynamicdns.park-your-domain.com/update?host=$host&domain=$domain&password=$key&ip=$ip")"
      if [[ ! "$resp" =~ "<ErrCount>0</ErrCount>" ]]; then
        echo "$resp"
        exit 1
      fi
    '';
    scriptArgs = let
      cfg = (import (inputs.secrets + "/ddns.nix")).silver;
    in "'${cfg.host}' '${cfg.domain}' '${cfg.key}'";
  };
  systemd.timers."update-ddns" = {
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnCalendar = "*-*-* *:00/10:00";
      OnBootSec = 30;
    };
  };
}
