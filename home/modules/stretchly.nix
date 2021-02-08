{ pkgs, ... }:
{
  home.packages = [
    pkgs.stretchly
  ];

  desktop-autostart."stretchly" = {
    desktopName = "Stretchly";
    exec = "stretchly";
  };
}
