{ ... }:
{
  # Fix Fn2 for MIIIW Keyboard.
  boot.extraModprobeConfig = ''
    options hid_apple fnmode=2
  '';

  # Enable TRIM for the WD harddisk.
  services.udev.extraRules = ''
    ACTION=="add|change", ATTRS{idVendor}=="1058", ATTRS{idProduct}=="25a2", SUBSYSTEM=="scsi_disk", ATTR{provisioning_mode}="unmap"
  '';
}
