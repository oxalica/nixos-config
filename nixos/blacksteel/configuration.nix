{ lib, config, pkgs, inputs, my, ... }:

{
  imports = [
    ./vm.nix

    ../modules/console-env.nix
    ../modules/device-fix.nix
    ../modules/kde-desktop
    ../modules/nix-cgroups.nix
    ../modules/nix-common.nix
    ../modules/nix-registry.nix
    ../modules/secure-boot.nix
  ] ++ lib.optional (inputs ? secrets) (inputs.secrets.nixosModules.blacksteel);

  nixpkgs.config.allowUnfreePredicate = drv:
    lib.elem (lib.getName drv) [
      "steam"
      "steam-original"
      "steam-run"
      "obsidian"
    ];
  nixpkgs.config.permittedInsecurePackages = [
    "electron-25.9.0" # Used by obsidian and logseq.
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

    kernelPackages = pkgs.linuxPackages_latest;
    kernelModules = [ "kvm-intel" ];
    extraModulePackages = [ ];

    # For hibernate-resume.
    # `sudo btrfs inspect-internal map-swapfile /var/swap/resume --resume-offset`
    # => 38868224
    resumeDevice = "/dev/disk/by-uuid/fbfe849d-2d2f-415f-88d3-65ded870e46b";
    kernelParams = [
      "resume_offset=38868224"
      "intel_pstate=passive"
    ];

    loader = {
      systemd-boot.consoleMode = "max"; # Don't clip boot menu.
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
    { device = "/var/swap/resume"; }
  ];

  # Hardware.

  powerManagement.cpuFreqGovernor = "schedutil";
  hardware = {
    cpu.intel.updateMicrocode = true;
    bluetooth.enable = true;
    logitech.wireless.enable = true;
    enableRedistributableFirmware = true; # Required for WIFI.
    opengl.extraPackages = with pkgs; [ intel-media-driver ]; # vaapi
  };
  console = {
    font = "${pkgs.terminus_font}/share/consolefonts/ter-v28n.psf.gz";
    useXkbConfig = true;
    earlySetup = true;
  };
  networking = {
    hostName = "blacksteel";
    firewall.logRefusedConnections = false;
  };

  time.timeZone = "Asia/Shanghai";

  # KDE pulls in pipewire via xdg-desktop-portal anyways.
  services.pipewire = {
    enable = true;
    pulse.enable = true;
    alsa.enable = true;
  };
  security.rtkit.enable = true; # pipewire expects this.
  sound.enable = false; # pipewire expects this.

  # Swap capslock and leftctrl only for the builtin keyboard.
  # Ref: https://wiki.archlinux.org/title/Map_scancodes_to_keycodes
  services.udev.extraHwdb = ''
    evdev:atkbd:dmi:bvnLENOVO:*:pvrThinkPadX1Carbon5th*
      KEYBOARD_KEY_3a=leftctrl
      KEYBOARD_KEY_1d=capslock
  '';

  # Users.

  sops.secrets.passwd.neededForUsers = true;
  programs.zsh.enable = true;
  users = {
    mutableUsers = false;
    users."oxa" = {
      isNormalUser = true;
      shell = pkgs.zsh;
      hashedPasswordFile = config.sops.secrets.passwd.path;
      uid = 1000;
      group = config.users.groups.oxa.name;
      extraGroups = [ "wheel" "kvm" "adbusers" "libvirtd" "wireshark" ];

      openssh.authorizedKeys.keys = with my.ssh.identities; [ oxa ];
    };
    groups."oxa".gid = 1000;
  };
  home-manager.users."oxa" =
    import ../../home/blacksteel.nix;

  # Services.

  services = {
    openssh = {
      enable = true;
      settings = {
        KbdInteractiveAuthentication = false;
        PasswordAuthentication = false;
        PermitRootLogin = "no";
      };
    };
    fstrim = {
      enable = true;
      interval = "Wed,Sat 02:00";
    };
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
    fwupd.enable = true;
  };

  nix = {
    buildMachines = [
      {
        hostName = "aluminum.lan.hexade.ca";
        maxJobs = 24;
        protocol = "ssh-ng";
        sshUser = "oxa";
        sshKey = "/etc/ssh/ssh_host_ed25519_key";
        systems = [ "x86_64-linux" "i686-linux" ];
        supportedFeatures = [ "kvm" "big-parallel" "nixos-test" "benchmark" ];
      }
    ];
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

  programs.steam.enable = true;

  programs.wireshark = {
    enable = true;
    package = pkgs.wireshark-qt;
  };

  programs.virt-manager.enable = true;

  environment.systemPackages = with pkgs; [
    ltunify
  ];

  system.stateVersion = "23.11";
}
