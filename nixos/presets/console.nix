{ lib, config, pkgs, ... }:
with lib;
{
  options.oxa-config.preset.console = mkEnableOption "console environment";

  config = mkIf config.oxa-config.preset.console {
    console.earlySetup = true;

    environment.systemPackages = with pkgs; [
      # tealdeer # Help
      # curl pv loop git file bc gnupg # Shell utils
      # htop # Stat
      screen
      cntr
    ];

    programs.less.enable = true;
    environment.variables.PAGER = "less --RAW-CONTROL-CHARS --quit-if-one-screen";

    programs.vim.defaultEditor = true;
    programs.mtr.enable = true;
    programs.iotop.enable = true;
    programs.iftop.enable = true;

    users.defaultUserShell = pkgs.zsh;
  };
}
