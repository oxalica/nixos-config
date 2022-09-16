{ config, ... }:
{
  boot.extraModprobeConfig = ''
    options hid_apple fnmode=2
  '';

  # FIXME: https://github.com/NixOS/nixpkgs/pull/191491
  boot.initrd.systemd.contents."/etc/modprobe.d/nixos.conf".source =
    config.environment.etc."modprobe.d/nixos.conf".source;
}
