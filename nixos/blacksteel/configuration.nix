{ lib, config, pkgs, inputs, my, ... }:

{
  imports = [
    ./vm.nix

    ../modules/console-env.nix
    ../modules/kde-desktop
    ../modules/miiiw-keyboard-fix.nix
    ../modules/nix-common.nix
    ../modules/nix-registry.nix
  ] ++ lib.optional (inputs ? secrets) (inputs.secrets.nixosModules.blacksteel);

  nixpkgs.config.allowUnfreePredicate = drv:
    lib.elem (lib.getName drv) [
      "steam"
      "steam-original"
      "steam-run"
    ];

  # Boot.

  boot = {
    initrd = {
      systemd.enable = true;
      availableKernelModules = [ "xhci_pci" "nvme" "rtsx_pci_sdmmc" ];
      kernelModules = [ ];
      luks.devices."luksroot" = {
        device = "/dev/disk/by-uuid/8e445c05-75cc-45c7-bebd-46a73cf50a74";
        allowDiscards = true;
        crypttabExtraOpts = [ "fido2-device=auto" ];
      };
    };

    kernelModules = [ "kvm-intel" ];
    extraModulePackages = [ ];

    # For hibernate-resume.
    # /var/swap/swap-resume: 131891830784 / 4096 = 32200154
    resumeDevice = "/dev/disk/by-uuid/fbfe849d-2d2f-415f-88d3-65ded870e46b";
    kernelParams = [ "resume_offset=32200154" ];

    loader = {
      systemd-boot = {
        enable = true;
        consoleMode = "max"; # Don't clip boot menu.
      };
      efi.canTouchEfiVariables = true;
      timeout = 1;
    };

    kernel.sysctl = {
      "kernel.sysrq" = "1";
      "net.ipv4.tcp_congestion_control" = "bbr";
    };
  };

  fileSystems = {
    "/" = {
      device = "/dev/disk/by-uuid/fbfe849d-2d2f-415f-88d3-65ded870e46b";
      fsType = "btrfs";
      options = [ "noatime" "compress=zstd:1" "subvol=@" ];
    };

    "/boot" = {
      device = "/dev/disk/by-uuid/9C91-4441";
      fsType = "vfat";
    };
  };

  swapDevices = [
    { device = "/var/swap/swap-resume"; }
  ];

  # Hardware.

  powerManagement.cpuFreqGovernor = "powersave";
  sound.enable = true;
  hardware = {
    cpu.intel.updateMicrocode = true;
    video.hidpi.enable = true;
    bluetooth.enable = true;
    logitech.wireless.enable = true;
    pulseaudio.enable = true;
    enableRedistributableFirmware = true; # Required for WIFI.
    opengl.extraPackages = with pkgs; [ intel-media-driver ]; # vaapi
  };
  console = {
    font = "${pkgs.terminus_font}/share/consolefonts/ter-v28n.psf.gz";
    useXkbConfig = true;
  };
  networking = {
    hostName = "blacksteel";
    firewall.logRefusedConnections = false;
  };

  time.timeZone = "Asia/Shanghai";

  # Users.

  sops.secrets.passwd.neededForUsers = true;
  programs.zsh.enable = true;
  users = {
    users."oxa" = {
      isNormalUser = true;
      shell = pkgs.zsh;
      passwordFile = config.sops.secrets.passwd.path;
      uid = 1000;
      group = config.users.groups.oxa.name;
      extraGroups = [ "wheel" "kvm" "adbusers" "libvirtd" ];
    };
    groups."oxa".gid = 1000;
  };
  home-manager.users."oxa" =
    import ../../home/blacksteel.nix;

  # Services.

  services = {
    xserver.xkbOptions = "ctrl:swapcaps";
    xserver.displayManager.defaultSession = "plasmawayland";
    openssh = {
      enable = true;
      forwardX11 = true;
      passwordAuthentication = false;
      kbdInteractiveAuthentication = false;
      permitRootLogin = "no";
    };
    fstrim.enable = true;
    timesyncd.enable = true;
    earlyoom = {
      enable = true;
      enableNotifications = true;
    };
    btrbk.instances.snapshot = {
      onCalendar = "*:00,30";
      settings = {
        timestamp_format = "long-iso";
        preserve_day_of_week = "monday";
        preserve_hour_of_day = "6";
        snapshot_preserve_min = "6h";
        volume."/" = {
          snapshot_dir = ".snapshots";
          subvolume."home/oxa".snapshot_preserve = "48h 7d";
          subvolume."home/oxa/storage".snapshot_preserve = "48h 7d 4w";
        };
      };
    };
  };

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

  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true;
    dedicatedServer.openFirewall = true;
  };

  environment.systemPackages = with pkgs; [
    ltunify
    virt-manager
    my.pkgs.btrfs_map_physical
  ];

  system.stateVersion = "21.11";
}
