# From: https://github.com/NickCao/nixos-riscv/blob/720c8ee6fc8eee85f741e309a4e0291dc3a90f59/flake.nix#L82
{ config, pkgs, lib, modulesPath, inputs, my, ... }:
{
  imports = [
    (modulesPath + "/installer/sd-card/sd-image.nix")
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

  sdImage = {
    populateRootCommands = ''
      mkdir -p ./files/boot
      ${config.boot.loader.generic-extlinux-compatible.populateCmd} -c ${config.system.build.toplevel} -d ./files/boot
    '';
    populateFirmwareCommands = "";
  };

  boot.loader = {
    grub.enable = false;
    generic-extlinux-compatible.enable = true;
  };
  boot.initrd.kernelModules = [ "nvme" "mmc_block" "mmc_spi" "spi_sifive" "spi_nor" "uas" "sdhci_pci" ];
  boot.kernelParams = [ ];
  boot.kernelPackages = pkgs.linuxPackages_latest;
  boot.kernelPatches = map (patch: { name = patch; patch = inputs.meta-sifive + "/recipes-kernel/linux/files/${patch}"; }) [
    "0001-riscv-sifive-fu740-cpu-1-2-3-4-set-compatible-to-sif.patch"
    "0002-riscv-sifive-unmatched-update-regulators-values.patch"
    "0003-riscv-sifive-unmatched-define-PWM-LEDs.patch"
    "0004-riscv-sifive-unmatched-add-gpio-poweroff-node.patch"
    "0005-SiFive-HiFive-Unleashed-Add-PWM-LEDs-D1-D2-D3-D4.patch"
    "0006-riscv-sifive-unleashed-define-opp-table-cpufreq.patch"
    "riscv-sbi-srst-support.patch"
  ] ++ [{
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
  }];

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
    # radeontop
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

  nix.extraOptions = ''
    experimental-features = nix-command flakes
  '';

  users = {
    mutableUsers = false;
    users.root.openssh.authorizedKeys.keys = [
      my.ssh.identities.oxa-invar
    ];
  };
}
