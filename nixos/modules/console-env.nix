{ lib, pkgs, ... }:
{
  # Reduce closure size.
  i18n.supportedLocales = lib.mkDefault [ "en_US.UTF-8/UTF-8" ];
  i18n.defaultLocale = lib.mkDefault "en_US.UTF-8";

  programs.less.enable = true;
  # Override the default value in nixos/modules/programs/environment.nix
  environment.variables.PAGER = "less";
  # Don't use `programs.less.envVariables.LESS`, which will be override by `LESS` set by `man`.
  environment.variables.LESS = lib.concatStringsSep " " [
    "--RAW-CONTROL-CHARS" # Only allow colors.
    "--mouse"
    "--wheel-lines=5"
  ];

  # Default:
  # - nano # Already have vim.
  # - perl # No.
  # - rsync strace # Already in systemPackages.
  environment.defaultPackages = [ ];

  environment.systemPackages = with pkgs; [
    procs ncdu swapview smartmontools # Stat
    strace pv exa fd ripgrep lsof jq loop bc file rsync dnsutils # Utilities
    gnupg age pwgen sops ssh-to-age # Crypto
    libarchive zstd # Compression
  ];

  programs.tmux.enable = true;

  programs.htop.enable = true;
  programs.iotop.enable = true;
  programs.iftop.enable = true;

  # Don't stuck for searching missing command.
  programs.command-not-found.enable = false;

  programs.vim.defaultEditor = true;

  programs.gnupg.agent = {
    enable = true;
    pinentryFlavor = lib.mkDefault "tty";
  };
}
