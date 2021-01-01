{ pkgs, ... }:
{
  systemd.user.services."rust-nightly-monitor" = {
    Unit.Description = "Monitor rust nightly version";
    Service.ExecStart = "${pkgs.writeShellScript "check-nightly-date" ''
      PATH=${pkgs.curl}/bin:${pkgs.coreutils}/bin:$PATH
      ret=$(curl -sL https://static.rust-lang.org/dist/channel-rust-nightly.toml 2>/dev/null | head -n2 | tail -n1)
      echo "$(date -u): $ret"
    ''}";
  };
  systemd.user.timers."rust-nightly-monitor" = {
    Timer = {
      OnCalendar = "*-*-* *:00,15,30,45:00";
    };
    Install.WantedBy = [ "timers.target" ];
  };
}
