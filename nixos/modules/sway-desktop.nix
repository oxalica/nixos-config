{ pkgs, ... }:
{
  imports = [ ./l10n.nix ];

  programs.sway.enable = true;

  services.udisks2.enable = true; # For `udiskie`.

  xdg.portal.enable = true;
  xdg.portal.extraPortals = [ pkgs.xdg-desktop-portal-gtk ]; # `wlr` is included by `programs.sway`.
}
