{ writeTextFile, python3, showmethekey }:
writeTextFile {
  name = "keystat";
  destination = "/lib/systemd/system/keystat.service";
  text = ''
    [Unit]
    Description=Keyboard statistics

    [Service]
    Type=exec
    ExecStart=${python3}/bin/python ${./keystat.py} ${showmethekey}/bin/showmethekey-cli
    DeviceAllow=char-input rw
    StateDirectory=keystat
    StateDirectoryMode=0700

    IPAddressDeny=any
    LockPersonality=yes
    MemoryDenyWriteExecute=yes
    NoNewPrivileges=yes
    PrivateMounts=yes
    ProtectClock=yes
    ProtectHostname=yes
    RestrictAddressFamilies=AF_UNIX AF_NETLINK AF_INET AF_INET6
    RestrictRealtime=yes
    RestrictSUIDSGID=yes
    SystemCallArchitectures=native
    SystemCallErrorNumber=EPERM
    SystemCallFilter=@system-service

    [Install]
    WantedBy=multi-user.target
  '';
}
