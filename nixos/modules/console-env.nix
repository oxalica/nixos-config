{ lib, pkgs, ... }:
{
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

  programs.iotop.enable = true;
  programs.iftop.enable = true;

  environment.systemPackages = with pkgs; [ htop procs tmux pv ];

  # Enable zsh related system configurations.
  # This is required for sddm to source /etc/set-environment in login script.
  programs.zsh.enable = true;
}
