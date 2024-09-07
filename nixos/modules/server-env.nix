{ lib, pkgs, ... }:
{
  # Reduce the closure size.
  i18n.supportedLocales = [ "en_US.UTF-8/UTF-8" ];
  i18n.defaultLocale = "en_US.UTF-8";
  fonts.fontconfig.enable = false;
  documentation = {
    enable = false;
    man.enable = false;
    info.enable = lib.mkDefault false;
  };

  # Partially copied from `nixos/modules/profiles/perlless.nix`.
  system.switch = lib.mkDefault {
    enable = false;
    enableNg = true;
  };
  system.disableInstallerTools = lib.mkDefault true;
  boot.enableContainers = lib.mkDefault false;

  # Default:
  # - perl # No.
  # - rsync strace # Already in systemPackages.
  environment.defaultPackages = [ ];

  environment.systemPackages = with pkgs; [
    # Utilities.
    # FIXME: compsize fails to build: https://github.com/NixOS/nixpkgs/issues/336006
    curl
    dnsutils
    fd
    file
    jq
    libarchive
    loop
    lsof
    ncdu
    procs
    pv
    ripgrep
    rsync
    strace
    tree
    zstd

    # Cryptography.
    age
    gnupg
    ssh-to-age

    # Version control.
    gitMinimal
  ];

  programs.less = {
    enable = true;
    lessopen = null;
  };
  environment.variables =
    let
      common = [
        "--RAW-CONTROL-CHARS" # Only allow colors.
        "--mouse"
        "--wheel-lines=5"
        "--LONG-PROMPT"
      ];
    in
    {
      PAGER = "less";
      # Don't use `programs.less.envVariables.LESS`, which will be override by `LESS` set by `man`.
      LESS = lib.concatStringsSep " " common;
      SYSTEMD_LESS = lib.concatStringsSep " " (
        common
        ++ [
          "--quit-if-one-screen"
          "--chop-long-lines"
          "--no-init" # Keep content after quit.
        ]
      );
    };

  programs.tmux.enable = true;

  programs.htop = {
    enable = true;
    # FIXME: Depends on perl.
    package = pkgs.htop.override { sensorsSupport = false; };
  };
  programs.iotop.enable = true;
  programs.iftop.enable = true;

  programs.mtr.enable = true;

  programs.command-not-found.enable = false;

  programs.vim = {
    enable = true;
    defaultEditor = true;
  };

  programs.nano.enable = lib.mkDefault false;
}
