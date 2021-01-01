{ lib, pkgs, ... }:

{
  systemd.user.services."ssh-scut0" = {
    Unit = {
      Description = "ssh to scut0 with dynamic port forwarding at localhost:1090";
      StartLimitIntervalSec = 3600;
      StartLimitBurst = 5;
    };
    Service = {
      Environment = "SSH_ASKPASS=";
      ExecStart = lib.concatStringsSep " " [
        "${pkgs.openssh}/bin/ssh"
        "-ND localhost:1090"
        "-o ServerAliveInterval=60"
        "-o ServerAliveCountMax=2"
        "-o ExitOnForwardFailure=yes"
        "scut0"
      ];
      Restart = "always";
      RestartSec = 30;
    };
    Install.WantedBy = [ "default.target" ];
  };
}
