{ lib, pkgs, ... }:
{
  # Reduce closure size.
  i18n.supportedLocales = lib.mkDefault [ "en_US.UTF-8/UTF-8" ];
  i18n.defaultLocale = lib.mkDefault "en_US.UTF-8";

  programs.vim.defaultEditor = true;

  programs.less.enable = true;
  # Override the default value in nixos/modules/programs/environment.nix
  environment.variables.PAGER = "less";
  # Don't use `programs.less.envVariables.LESS`, which will be override by `LESS` set by `man`.
  environment.variables.LESS = lib.concatStringsSep " " [
    "--RAW-CONTROL-CHARS" # Only allow colors.
    "--mouse"
    "--wheel-lines=5"
  ];

  environment.systemPackages = with pkgs; [
    htop procs ncdu swapview smartmontools # Stat
    pv exa fd ripgrep lsof jq loop bc file rsync dnsutils # Utilities
    gnupg age pwgen # Crypto
    libarchive # Compression
  ];

  programs.tmux.enable = true;

  # programs.htop.enable = true; # Not available in nixos-21.05
  programs.iotop.enable = true;
  programs.iftop.enable = true;
}
