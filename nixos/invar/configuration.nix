{ lib, config, pkgs, inputs, my, ... }:
{
  imports = [
    ./btrbk.nix

    ../modules/console-env.nix
    ../modules/nix-binary-cache-mirror.nix
    ../modules/nix-common.nix
    ../modules/nix-registry.nix
    ../modules/sway-desktop.nix
  ] ++ lib.optional (inputs ? secrets) inputs.secrets.nixosModules.invar;

  sops.age.sshKeyPaths = lib.mkForce [ "/var/ssh/ssh_host_ed25519_key" ];

  nixpkgs.config.allowUnfreePredicate =
    drv: lib.elem (lib.getName drv) [
      "steam" "steam-original"
    ];

  # Boot.

  boot = {
    initrd = {
      # Test.
      systemd.enable = true;

      availableKernelModules = [ "xhci_pci" "ahci" "nvme" "usbhid" ];
      kernelModules = [ ];
      luks.devices."invar-luks" = {
        device = "/dev/disk/by-uuid/aa50ce23-65c4-4b9a-8484-641a06a9d08c";
        allowDiscards = true;
      };
    };

    kernelModules = [
      "kvm-amd"
      "nct6775" # Fan control
    ];
    extraModulePackages = [ ];

    kernel.sysctl = {
      "net.ipv4.ip_forward" = 1;
      "kernel.sysrq" = 1;
      "net.ipv4.tcp_congestion_control" = "bbr";
    };

    loader = {
      systemd-boot.enable = true;
      systemd-boot.consoleMode = "max"; # Don't clip boot menu.
      efi.canTouchEfiVariables = false;
      timeout = 1;
    };

    # For dev.
    binfmt.emulatedSystems = [ "riscv64-linux" ];
  };

  fileSystems = {
    "/" = {
      device = "/dev/mapper/invar-luks";
      fsType = "btrfs";
      # zstd:1  W: ~510MiB/s
      # zstd:3  W: ~330MiB/s
      options = [ "compress=zstd:1" "noatime" "subvol=/@" ];
    };

    "/boot" = {
      device = "/dev/disk/by-uuid/0CEB-39A8";
      fsType = "vfat";
    };
  };

  swapDevices = [
    {
      device = "/var/swapfile";
      # FIXME: Auto creation sucks on btrfs.
      # size = 16 * 1024; # 16G
    }
  ];

  # Hardware.

  time.timeZone = "Asia/Shanghai";
  powerManagement.cpuFreqGovernor = "ondemand";
  hardware = {
    enableRedistributableFirmware = true;
    video.hidpi.enable = true;
    cpu.amd.updateMicrocode = true;
    bluetooth.enable = true;
    logitech.wireless.enable = true;
    logitech.wireless.enableGraphical = true; # Solaar.
  };
  console = {
    font = "${pkgs.terminus_font}/share/consolefonts/ter-v28n.psf.gz";
    useXkbConfig = true;
  };
  networking = {
    hostName = "invar";
    search = [ "lan." ];
    useNetworkd = true;
    useDHCP = false;
    interfaces = {
      enp10s0.useDHCP = true;
      wlp9s0.useDHCP = true;
    };
    wireless = {
      enable = true;
      userControlled.enable = true;
    };
  };
  systemd.network.wait-online = {
    anyInterface = true;
    timeout = 15;
  };

  # Users.

  sops.secrets.passwd.neededForUsers = true;
  programs.zsh.enable = true;
  users = {
    mutableUsers = false;
    users."oxa" = {
      isNormalUser = true;
      shell = pkgs.zsh;
      passwordFile = config.sops.secrets.passwd.path;
      uid = 1000;
      group = config.users.groups.oxa.name;
      extraGroups = [ "wheel" "libvirtd" ];
    };
    groups."oxa".gid = 1000;
  };
  home-manager.users."oxa" = import ../../home/invar.nix;

  # Services.

  security.rtkit.enable = true; # Better installed with pipewire.
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    pulse.enable = true;
  };

  services.xserver.xkbOptions = "ctrl:swapcaps";

  services.timesyncd.enable = true;

  services.fstrim = {
    enable = true;
    interval = "Sat";
  };

  services.logind.extraConfig = ''
    HandlePowerKey=suspend
  '';

  services.openssh = {
    enable = true;
    passwordAuthentication = false;
    kbdInteractiveAuthentication = false;
    permitRootLogin = "no";
    hostKeys = [
      {
        type = "rsa";
        path = "/var/ssh/ssh_host_rsa_key";
        bits = 4096;
      }
      {
        type = "ed25519";
        path = "/var/ssh/ssh_host_ed25519_key";
        rounds = 100;
      }
    ];
  };

  services.earlyoom = {
    enable = true;
    freeMemThreshold = 5;
    freeSwapThreshold = 10;
    enableNotifications = true;
  };

  services.transmission = {
    enable = true;
    home = "/home/transmission";
  };
  users.groups."transmission".members = [ config.users.users.oxa.name ];

  virtualisation.libvirtd = {
    enable = true;
    onBoot = "ignore";
  };

  nix.settings.experimental-features = [ "ca-derivations" "repl-flake" ];

  # Global ssh settings. Also for remote builders.
  programs.ssh = {
    knownHosts = my.ssh.knownHosts;
    extraConfig = ''
      Include ${config.sops.secrets.ssh-hosts.path}
    '';
  };
  sops.secrets.ssh-hosts = {
    sopsFile = ../../secrets/ssh.yaml;
    mode = "0444";
  };

  programs.adb.enable = true;
  users.groups."adbusers".members = [ config.users.users.oxa.name ];

  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true;
    dedicatedServer.openFirewall = true;
  };

  environment.etc = {
    "machine-id".source = "/var/machine-id";
    "ssh/ssh_host_rsa_key".source = "/var/ssh/ssh_host_rsa_key";
    "ssh/ssh_host_rsa_key.pub".source = "/var/ssh/ssh_host_rsa_key.pub";
    "ssh/ssh_host_ed25519_key".source = "/var/ssh/ssh_host_ed25519_key";
    "ssh/ssh_host_ed25519_key.pub".source = "/var/ssh/ssh_host_ed25519_key.pub";
  };

  environment.systemPackages = with pkgs; [
    cntr # Debug nix build.
    virt-manager
    solaar # Logitech devices control.
    compsize
  ];

  system.stateVersion = "21.11";
}
