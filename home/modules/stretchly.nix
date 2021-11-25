{ pkgs, ... }:
{
  home.packages = [
    pkgs.stretchly
  ];

  # FIXME: Enable when bumped to 1.8.
  # https://github.com/NixOS/nixpkgs/pull/147374
  # xdg.configFile."autostart/stretchly.desktop".source =
  #   "${pkgs.stretchly}/share/applications/stretchly.desktop";
}
