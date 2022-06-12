{ lib, pkgs, ... }:
{
  # Reduce the closure size.
  i18n.supportedLocales = lib.mkDefault [ "en_US.UTF-8/UTF-8" ];
  i18n.defaultLocale = lib.mkDefault "en_US.UTF-8";

  # Default:
  # - nano # Already have vim.
  # - perl # No.
  # - rsync strace # Already in systemPackages.
  environment.defaultPackages = [ ];

  environment.systemPackages = with pkgs; [
    cntr # Nix
    procs ncdu swapview smartmontools # Stat
    curl git rawmv strace pv exa fd ripgrep lsof jq loop bc file rsync dnsutils # Utilities
    gnupg age pwgen sops ssh-to-age # Crypto
    libarchive zstd # Compression
  ];

  programs.less = {
    enable = true;
    lineEditingKeys = {
      "^W" = "word-delete";
      "^P" = "back-complete";
      "^N" = "forw-complete";
    };
 };
  # Don't use `programs.less.envVariables.LESS`, which will be override by `LESS` set by `man`.
  environment.variables.LESS = lib.concatStringsSep " " [
    "--RAW-CONTROL-CHARS" # Only allow colors.
    "--mouse"
    "--wheel-lines=5"
  ];

  programs.tmux.enable = true;

  programs.htop.enable = true;
  programs.iotop.enable = true;
  programs.iftop.enable = true;

  programs.mtr.enable = true;

  # Don't stuck for searching missing commands.
  programs.command-not-found.enable = false;

  programs.vim.defaultEditor = true;

  programs.gnupg.agent = {
    enable = true;
    pinentryFlavor = lib.mkDefault "tty";
  };
}
