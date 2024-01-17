{ lib, config, pkgs, inputs, my, ... }:
{
  imports = [
    ./btrbk.nix

    ../modules/console-env.nix
    ../modules/device-fix.nix
    ../modules/nix-cgroups.nix
    ../modules/nix-common.nix
    ../modules/nix-registry.nix
    ../modules/secure-boot.nix
    ../modules/sway-desktop.nix
    ../modules/systemd-unit-protections.nix
  ] ++ lib.optional (inputs ? secrets) inputs.secrets.nixosModules.invar;

  sops.age.sshKeyPaths = lib.mkForce [ "/var/ssh/ssh_host_ed25519_key" ];

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
    kernelPackages = pkgs.linuxPackages_latest;
    kernelPatches = [
      {
        name = "enable-zone-device";
        patch = null;
        extraStructuredConfig.BLK_DEV_ZONED = lib.kernel.yes;
      }
    ];

    kernelModules = [ "kvm-amd" ];
    kernelParams = [
      # Try fixing nvme unavailability issue after S3 resume.
      # See: https://wiki.archlinux.org/title/Solid_state_drive/NVMe#Controller_failure_due_to_broken_suspend_support
      "amd_iommu=fullflush"
    ];

    initrd = {
      systemd.enable = true;

      availableKernelModules = [ "xhci_pci" "ahci" "usbhid" ];
      kernelModules = [ "nvme" ];

      luks.devices."invar-luks2" = {
        device = "/dev/disk/by-uuid/89a01448-a7d6-40c3-8ad0-2257bcd54f46";
        allowDiscards = true;
        # https://blog.cloudflare.com/speeding-up-linux-disk-encryption/
        crypttabExtraOpts = [ "fido2-device=auto" "no-read-workqueue" "no-write-workqueue" ];
      };
    };

    kernel.sysctl = {
      "net.ipv4.ip_forward" = 1;
      "kernel.sysrq" = 1;
      "net.ipv4.tcp_congestion_control" = "bbr";

      "vm.swappiness" = 150;
    };

    loader = {
      systemd-boot.consoleMode = "max"; # Don't clip boot menu.
      efi.canTouchEfiVariables = false;
      timeout = 1;
    };

    # For dev.
    binfmt.emulatedSystems = [ "riscv64-linux" ];
  };

  fileSystems = {
    "/" = {
      device = "/dev/disk/by-uuid/7219f4b1-a9d1-42a4-bfc9-386fa919d44b";
      fsType = "btrfs";
      # zstd:1  W: ~510MiB/s
      # zstd:3  W: ~330MiB/s
      options = [ "compress=zstd:1" "noatime" "subvol=/@" ];
    };

    "/boot" = {
      device = "/dev/disk/by-uuid/0A3C-5592";
      fsType = "vfat";
    };
  };

  # Ref: https://github.com/NickCao/flakes/blob/28c25f4fc9eac535afa8c350fc9769f5fa59dd18/modules/baseline.nix#L48
  services.zram-generator = {
    enable = true;
    settings.zram0 = {
      compression-algorithm = "zstd";
      # The typical compression rate is ~20% for zstd in experience.
      # So 2x RAM is expected to be <40% RAM after compression.
      zram-size = "ram * 2";
    };
  };

  services.udev.packages = [ my.pkgs.ublk-allow-unprivileged ];

  # Hardware.

  time.timeZone = "Asia/Shanghai";
  powerManagement.cpuFreqGovernor = "performance";
  hardware = {
    enableRedistributableFirmware = true;
    cpu.amd.updateMicrocode = true;
    bluetooth.enable = true;
    logitech.wireless.enable = true;
    logitech.wireless.enableGraphical = true; # Solaar.
  };
  console = {
    font = "${pkgs.terminus_font}/share/consolefonts/ter-v28n.psf.gz";
    useXkbConfig = true;
    earlySetup = true;
  };
  networking = {
    hostName = "invar";
    search = [ "lan." ];
    useNetworkd = true;
    useDHCP = true; # PCIE device changes would cause name changes.
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
  programs.zsh.enable = true; # As shell.
  users.mutableUsers = false;

  users.users."oxa" = {
    isNormalUser = true;
    shell = pkgs.zsh;
    hashedPasswordFile = config.sops.secrets.passwd.path;
    uid = 1000;
    group = config.users.groups.oxa.name;
    extraGroups = [ "wheel" "libvirtd" ];

    openssh.authorizedKeys.keys = with my.ssh.identities; [ oxa ];
  };
  users.groups."oxa".gid = 1000;
  home-manager.users."oxa" = import ../../home/invar.nix;

  # Services.
  nix.settings.cores = 14;
  systemd.services.nix-daemon.serviceConfig = {
    CPUWeight = 30;
    IOWeight = 30;

    MemoryMax = "80%";
    MemoryHigh = "75%";
    MemorySwapMax = "50%";
  };

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
    interval = "Wed,Sat 02:00";
  };

  services.logind.extraConfig = ''
    HandlePowerKey=suspend
  '';

  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = false;
      KbdInteractiveAuthentication = false;
      PermitRootLogin = "no";
    };
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
    qemu.vhostUserPackages = [ pkgs.virtiofsd ];
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
  users.groups."adbusers".members = [ config.users.users.oxa.name ];

  programs.steam.enable = true;

  programs.wireshark = {
    enable = true;
    package = pkgs.wireshark-qt;
  };
  users.groups."wireshark".members = [ config.users.users.oxa.name ];

  programs.virt-manager.enable = true;

  services.printing.cups-pdf.enable = true;

  services.btrfs.autoScrub = {
    enable = true;
    fileSystems = [ "/" ];
    interval = "monthly";
  };

  environment.etc = {
    "machine-id".source = "/var/machine-id";
    "ssh/ssh_host_rsa_key".source = "/var/ssh/ssh_host_rsa_key";
    "ssh/ssh_host_rsa_key.pub".source = "/var/ssh/ssh_host_rsa_key.pub";
    "ssh/ssh_host_ed25519_key".source = "/var/ssh/ssh_host_ed25519_key";
    "ssh/ssh_host_ed25519_key.pub".source = "/var/ssh/ssh_host_ed25519_key.pub";
  };

  environment.systemPackages = with pkgs; [
    radeontop
    solaar # Logitech devices control.

    wineWowPackages.staging
    lutris
  ];

  system.stateVersion = "23.11";
}
