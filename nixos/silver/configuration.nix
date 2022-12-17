{ lib, config, pkgs, inputs, modulesPath, ... }:

{
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")

    ../modules/console-env.nix
    ../modules/nix-binary-cache-mirror.nix
    ../modules/nix-common.nix
  ] ++ lib.optional (inputs ? secrets) (inputs.secrets.nixosModules.silver);

  # Initrd.
  boot.initrd.availableKernelModules = [ "xhci_pci" "ahci" "usb_storage" "sd_mod" ];
  boot.kernelModules = [ "kvm-intel" ];
  boot.extraModulePackages = [ ];

  # Kernel.
  boot.kernel.sysctl = {
    "net.ipv4.tcp_congestion_control" = "bbr";
    "vm.swappiness" = 30;
  };
  boot.binfmt.emulatedSystems = [ "riscv64-linux" ];

  # Boot loader.
  boot.loader = {
    systemd-boot.enable = true;
    efi.canTouchEfiVariables = true;
    timeout = 1;
  };

  # Filesystems.
  fileSystems."/" = {
    device = "/dev/disk/by-uuid/3c855cef-48db-4ba5-84fc-0d8055fbe7bd";
    fsType = "ext4";
  };
  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/F800-4055";
    fsType = "vfat";
  };

  swapDevices = [
    {
      device = "/var/swapfile";
      size = 8192; # MiB
    }
  ];

  # User.
  sops.secrets.passwd.neededForUsers = true;
  users = {
    mutableUsers = false;
    users."oxa" = {
      isNormalUser = true;
      passwordFile = config.sops.secrets.passwd.path;
      uid = 1000;
      group = config.users.groups.oxa.name;
      extraGroups = [ "wheel" ];
    };
    groups."oxa".gid = 1000;
  };
  security.sudo.wheelNeedsPassword = false;

  # Networking.

  time.timeZone = "Asia/Shanghai";

  networking.useDHCP = false;
  networking.interfaces.enp0s31f6.useDHCP = true;
  networking.hostName = "silver";
  networking.firewall = {
    enable = true;
    allowedTCPPorts = [ 23333 23334 23335 23336 ];
  };

  services.openssh = {
    enable = true;
    ports = [ 23333 ];
    passwordAuthentication = false;
    extraConfig = ''
      ClientAliveInterval 70
      ClientAliveCountMax 3
    '';
  };

  sops.secrets.reverse-ssh-host.restartUnits = [ "reverse-ssh.service" ];
  systemd.services."reverse-ssh" = {
    wants = [ "network-online.target" ];
    after = [ "network-online.target" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Type = "simple";
      Restart = "always";
      RestartSec = 60;
      SupplementaryGroups = [ config.users.groups.keys.name ];
    };
    path = [ pkgs.openssh ];
    script = ''
      ssh -N -R 2222:localhost:${toString (lib.head config.services.openssh.ports)} \
        -o ServerAliveInterval=60 \
        -o ServerAliveCountMax=3 \
        -o StrictHostKeyChecking=yes \
        -o IdentityFile=/etc/ssh/ssh_host_ed25519_key \
        "$(cat ${config.sops.secrets.reverse-ssh-host.path})"
    '';
  };

  # Hardware.
  hardware.cpu.intel.updateMicrocode = true;
  powerManagement.cpuFreqGovernor = "ondemand";

  system.stateVersion = "22.11";
}
