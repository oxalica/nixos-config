{ lib, config, pkgs, ... }:
let
  timer = "*-*-* 03:00:00";
  dirs = [
    "${home}/storage"
    "${home}/storage/history"
  ];

  # Keep at least this number of snapshots.
  keepSnapshots = 30;
  # Do not delete snapshots younger than these days.
  keepDays = 30;

  home = config.home.homeDirectory;

in
{
  systemd.user.services."auto-snapshot-storage" = {
    Unit.Description = "Create btrfs snapshot of storage";
    Service = {
      Environment = [
        "PATH=${lib.makeBinPath (with pkgs; [ coreutils gnugrep btrfs-progs ])}"
      ];
      ExecStart = "${pkgs.writeShellScript "auto-snapshot-storage.sh" ''
        set -eo pipefail
        exec 2>&1

        dels=()
        for dir in ${lib.escapeShellArgs dirs}; do
          datetime="$(date -u +"%Y-%m-%dT%H:%M:%SZ")"
          del_datetime="$(date -u +"%Y-%m-%dT%H:%M:%SZ" -d "-${toString keepDays} days")"
          snap_dir="$dir/.snapshot-auto"
          echo "Create snapshot: $snap_dir/$datetime"
          btrfs -q subvolume snapshot -r "$dir" "$snap_dir/$datetime"

          snapshots=$(ls --reverse "$snap_dir/" | \
            grep -E "^[0-9]{4}-[0-9]{2}-[0-9]{2}T[0-9]{2}:[0-9]{2}:[0-9]{2}Z$" | \
            tail +${toString (keepSnapshots + 1)})
          for name in $snapshots; do
            if [[ "$name" < "$del_datetime" ]]; then
              dels+=( "$snap_dir/$name" )
            fi
          done
        done

        if [[ "''${#dels[@]}" -ne 0 ]]; then
          echo "Delete outdated snapshots: ''${dels[*]}"
          dels2=()
          for name in "''${dels[@]}"; do
            mv "$name"{,W}
            btrfs property set "$name"W ro false
            dels2+=( "$name"W )
          done
          btrfs subvolume delete --commit-after "''${dels2[@]}"
        fi
      ''}";
    };
  };
  systemd.user.timers."auto-snapshot-storage" = {
    Timer.OnCalendar = timer;
    Install.WantedBy = [ "timers.target" ];
  };
}
