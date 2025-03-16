{ lib, pkgs, my, ... }:
{
  # Reduce the closure size.
  i18n.supportedLocales = lib.mkDefault [ "en_US.UTF-8/UTF-8" ];
  i18n.defaultLocale = lib.mkDefault "en_US.UTF-8";

  fonts.fontconfig.enable = lib.mkDefault false;

  # Default:
  # - perl # No.
  # - rsync strace # Already in systemPackages.
  environment.defaultPackages = [ ];

  environment.systemPackages = with pkgs; [
    cntr # Nix helpers.
    btdu procs ncdu swapview smartmontools pciutils usbutils # System info.
    moreutils curl git strace pv tree fd ripgrep lsof jq bc file rsync dnsutils # Utilities.
    compsize e2fsprogs # Filesystems.
    gnupg age pwgen sops ssh-to-age # Crypto.
    libarchive zstd # Compression.

    my.pkgs.nixos-rebuild-shortcut
  ];

  programs.less = {
    enable = true;
    lessopen = null;
  };
  environment.variables = let
    common = [
      "--RAW-CONTROL-CHARS" # Only allow colors.
      "--mouse"
      "--wheel-lines=5"
      "--LONG-PROMPT"
    ];
  in {
    PAGER = "less";
    # Don't use `programs.less.envVariables.LESS`, which will be override by `LESS` set by `man`.
    LESS = lib.concatStringsSep " " common;
    SYSTEMD_LESS = lib.concatStringsSep " " (common ++ [
      "--quit-if-one-screen"
      "--chop-long-lines"
      "--no-init" # Keep content after quit.
    ]);
  };

  programs.tmux.enable = true;

  programs.htop.enable = true;
  programs.iotop.enable = true;
  programs.iftop.enable = true;

  programs.mtr.enable = true;

  # Don't stuck for searching missing commands.
  programs.command-not-found.enable = false;

  programs.vim = {
    enable = true;
    defaultEditor = true;
  };

  programs.nano.enable = lib.mkDefault false;
}
