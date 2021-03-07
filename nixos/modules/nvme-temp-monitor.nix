{ lib, pkgs, ... }:
let
  dev = "/dev/nvme0n1";
  log = "/var/log/nvme_temp.csv";
in {
  systemd.services."nvme-temp-monitor" = {
    description = "Monitor NVME SSD temperature";
    path = with pkgs; [ smartmontools jq ];
    script = ''
      set -eo pipefail
      ret=( $(smartctl --json -a "${dev}" | jq '.nvme_smart_health_information_log | .temperature, .warning_temp_time, .critical_comp_time') )
      time="$(date -u +"%Y-%m-%dT%H:%M:%SZ")"
      echo "$time,''${ret[0]},''${ret[1]},''${ret[2]}" >>"${log}"
    '';
  };
  systemd.timers."nvme-temp-monitor" = {
    wantedBy = [ "timers.target" ];
    timerConfig.OnCalendar = "*-*-* *:*:00";
  };
}
