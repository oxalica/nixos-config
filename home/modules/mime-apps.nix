{ lib, pkgs, config, ... }:
{
  assertions = [
    {
      assertion =
        config.programs.firefox.enable &&
        config.programs.feh.enable &&
        config.programs.neovim.enable &&
        config.programs.alacritty.enable;
      message = "firefox, feh, and neovim are used in MIME apps";
    }
  ];

  home.packages = with pkgs; [
    handlr
    (lib.hiPrio (pkgs.writeShellScriptBin "xdg-open" ''
      exec ${handlr}/bin/handlr open "$@"
    ''))
  ];

  xdg.mimeApps = {
    enable = true;
    defaultApplications = {
      "application/xhtml+xml" = "firefox.desktop";
      "image/*" = "feh.desktop";
      "text/*" = "nvim.desktop";
      "text/html" = "firefox.desktop";
      "text/xml" = "firefox.desktop";
      "x-scheme-handler/ftp" = "firefox.desktop";
      "x-scheme-handler/http" = "firefox.desktop";
      "x-scheme-handler/https" = "firefox.desktop";
      "x-scheme-handler/terminal" = "alacritty.desktop";
    };
  };
}
