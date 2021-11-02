{ pkgs, ... }:
{
  home.packages = [
    pkgs.stretchly
  ];

  xdg.configFile."autostart/stretchly.desktop".source =
    "${pkgs.stretchly}/share/applications/stretchly.desktop";
}
