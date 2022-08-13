{ pkgs, ... }:
{
  imports = [ ./l10n.nix ];

  security.polkit.enable = true;
  security.pam.services.swaylock = {};

  hardware.opengl.enable = true;

  services.udisks2.enable = true; # For `udiskie`.

  programs.dconf.enable = true;
  programs.xwayland.enable = true;

  xdg.portal.wlr.enable = true;
  xdg.portal.extraPortals = with pkgs; [ xdg-desktop-portal-gtk ];
}
