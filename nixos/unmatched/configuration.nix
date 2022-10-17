# From: https://github.com/NickCao/nixos-riscv/blob/720c8ee6fc8eee85f741e309a4e0291dc3a90f59/flake.nix#L82
{ config, pkgs, lib, modulesPath, inputs, my, ... }:
{
  imports = [
    # (modulesPath + "/installer/sd-card/sd-image.nix")
    # ../modules/console-env.nix
  ];

  disabledModules = [ "profiles/all-hardware.nix" ];

  # For firmware.
  nixpkgs.config.allowUnfree = true;

  nixpkgs.overlays = [
    (final: prev: {
      boost = final.boost17x;
    })
  ];

  /*
  sdImage = {
    populateRootCommands = ''
      mkdir -p ./files/boot
      ${config.boot.loader.generic-extlinux-compatible.populateCmd} -c ${config.system.build.toplevel} -d ./files/boot
    '';
    populateFirmwareCommands = "";
  };
  */

  boot.loader = {
    grub.enable = false;
    generic-extlinux-compatible.enable = true;
    generic-extlinux-compatible.configurationLimit = 5;
  };
  boot.initrd.kernelModules = [ "nvme" "mmc_block" "mmc_spi" "spi_sifive" "spi_nor" "uas" "sdhci_pci" ];
  boot.kernelParams = [ "loglevel=7" ]; # DEBUG
  boot.kernelPackages = pkgs.linuxPackages_latest;
  boot.kernelPatches = map (patch: { name = patch; patch = inputs.meta-sifive + "/recipes-kernel/linux/files/${patch}"; }) [
    "0001-riscv-sifive-fu740-cpu-1-2-3-4-set-compatible-to-sif.patch"
    "0002-riscv-sifive-unmatched-update-regulators-values.patch"
    "0003-riscv-sifive-unmatched-define-PWM-LEDs.patch"
    "0004-riscv-sifive-unmatched-add-gpio-poweroff-node.patch"
    "0005-SiFive-HiFive-Unleashed-Add-PWM-LEDs-D1-D2-D3-D4.patch"
    "0006-riscv-sifive-unleashed-define-opp-table-cpufreq.patch"
    "riscv-sbi-srst-support.patch"
  ] ++ [
    {
      name = "sifive";
      patch = null;
      extraConfig = ''
        SOC_SIFIVE y
        PCIE_FU740 y
        PWM_SIFIVE y
        EDAC_SIFIVE y
        SIFIVE_L2 y
        RISCV_ERRATA_ALTERNATIVE y
        ERRATA_SIFIVE y
        ERRATA_SIFIVE_CIP_453 y
        ERRATA_SIFIVE_CIP_1200 y
      '';
    }
    # https://github.com/zhaofengli/unmatched-nixos/blob/e04fff15b62846d5151c0d98da79398e238b69f6/pkgs/linux/default.nix
    {
      name = "cpufreq";
      patch = null;
      extraConfig = ''
        CPU_IDLE y
        CPU_FREQ y
        CPU_FREQ_DEFAULT_GOV_USERSPACE y
        CPU_FREQ_GOV_PERFORMANCE y
        CPU_FREQ_GOV_USERSPACE y
        CPU_FREQ_GOV_ONDEMAND y
      '';
    }
  ];

  fileSystems."/" = {
    device = "/dev/disk/by-uuid/27b822c9-7087-4f52-8b7e-88a0ac476808";
    fsType = "ext4";
  };
  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/3A9E-9961";
    fsType = "vfat";
  };
  swapDevices = [
    {
      device = "/var/swapfile";
      size = 4 * 1024; # 4G
    }
  ];

  systemd.services."pwm-fan" = {
    description = "PWM fan control";
    wantedBy = [ "basic.target" ];
    after = [ "-.mount" ];
    path = [ pkgs.coreutils ];

    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      Restart = "on-failure";
    };

    script = ''
      cd /sys/class/pwm/pwmchip4
      [[ -d pwm2 ]] || echo 2 >export
      cd pwm2
      echo 0 >duty_cycle || true
      echo 10000000 >period
      echo 800000 >duty_cycle
      echo 1 >enable
    '';

    preStop = ''
      cd /sys/class/pwm/pwmchip4
      [[ ! -d pwm2 ]] || echo 0 >pwm2/enable
    '';
  };

  documentation.nixos.enable = false;
  services.udisks2.enable = false;
  security.polkit.enable = false;

  services.getty.autologinUser = "root";
  services.openssh.enable = true;

  environment.systemPackages = with pkgs; [
    neofetch
    lm_sensors
    pciutils
    htop
    git
    lsof
    btrfs-progs
    tmux
  ];

  hardware.firmware = with pkgs; [ firmwareLinuxNonfree ];
  # hardware.opengl.enable = true;
  # programs.sway.enable = true;

  i18n.supportedLocales = lib.mkDefault [ "en_US.UTF-8/UTF-8" ];
  i18n.defaultLocale = lib.mkDefault "en_US.UTF-8";
  fonts.fontconfig.enable = false;
  programs.command-not-found.enable = false;

  # Don't use vim_configurable.
  programs.vim.defaultEditor = true;

  nix = {
    extraOptions = ''
      experimental-features = nix-command flakes
      keep-outputs = true # Keep build-dependencies.
      flake-registry = /etc/nix/registry.json
    '';

    registry = {
      nixpkgs = {
        from = { id = "nixpkgs"; type = "indirect"; };
        flake = inputs.nixpkgs-unmatched;
      };
    };

    binaryCaches = lib.mkBefore [
      "https://riscv64.cachix.org"
    ];
  };

  users = {
    mutableUsers = false;
    users.root.openssh.authorizedKeys.keys = [
      my.ssh.identities.oxa-invar
      my.ssh.identities.oxa-blacksteel
      my.ssh.identities.invar
      my.ssh.identities.blacksteel
    ];
  };
}
