{ ... }:
{
  console.earlySetup = true;

  boot.kernelModules = [
    "nct6775" # Fan control
  ];

  boot.kernel.sysctl = {
    "kernel.sysrq" = 1;
    # "vm.swappiness" = 10;
    "net.ipv4.tcp_congestion_control" = "bbr";
  };

  swapDevices = [
    {
      device = "/var/swapfile";
      size = 16 * 1024; # MiB
    }
  ];

  hardware.cpu.amd.updateMicrocode = true;
  hardware.bluetooth.enable = true;

  hardware.pulseaudio.enable = true;
  sound.enable = true;
  users.groups."audio".members = [ "oxa" ];
}
