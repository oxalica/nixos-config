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

  # Common Settings:
  # INTERVAL=3
  #
  # Settings of hwmon0/pwm3:
  #   Depends on hwmon0/temp7_input
  #   Controls hwmon0/fan3_input
  #   MINTEMP=65
  #   MAXTEMP=85
  #   MINSTART=150
  #   MINSTOP=0
  #
  # Settings of hwmon0/pwm1:
  #   Depends on hwmon0/temp7_input
  #   Controls hwmon0/fan1_input
  #   MINTEMP=65
  #   MAXTEMP=85
  #   MINSTART=90
  #   MINSTOP=90
  #   MINPWM=90
  hardware.fancontrol = {
    # enable = true;
    config = ''
      INTERVAL=1
      # DEVPATH=hwmon0=devices/platform/nct6775.656 hwmon1=devices/pci0000:00/0000:00:18.3
      # DEVNAME=hwmon0=nct6792 hwmon1=k10temp
      FCTEMPS=/sys/class/hwmon/hwmon0/pwm3=/sys/class/hwmon/hwmon1/temp1_input /sys/class/hwmon/hwmon0/pwm1=/sys/class/hwmon/hwmon1/temp1_input
      FCFANS=/sys/class/hwmon/hwmon0/pwm3=/sys/class/hwmon/hwmon0/fan3_input /sys/class/hwmon/hwmon0/pwm1=/sys/class/hwmon/hwmon0/fan1_input

      MINTEMP= /sys/class/hwmon/hwmon0/pwm3=60  /sys/class/hwmon/hwmon0/pwm1=60
      MAXTEMP= /sys/class/hwmon/hwmon0/pwm3=86  /sys/class/hwmon/hwmon0/pwm1=82
      MINSTART=/sys/class/hwmon/hwmon0/pwm3=90  /sys/class/hwmon/hwmon0/pwm1=90
      MINSTOP= /sys/class/hwmon/hwmon0/pwm3=90  /sys/class/hwmon/hwmon0/pwm1=90
      MINPWM=  /sys/class/hwmon/hwmon0/pwm3=70  /sys/class/hwmon/hwmon0/pwm1=90
    '';
  };
}
