{ config, ... }:
{
  # Fix Fn2 for MIIIW Keyboard.
  boot.extraModprobeConfig = ''
    options hid_apple fnmode=2
  '';
}
