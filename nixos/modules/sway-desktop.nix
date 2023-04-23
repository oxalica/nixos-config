{ pkgs, ... }:
{
  imports = [ ./l10n.nix ];

  programs.sway.enable = true;

  # For `udiskie`.
  services.udisks2.enable = true;

  xdg.portal = {
    enable = true;
    xdgOpenUsePortal = true;
    wlr.enable = true;
    extraPortals = [ pkgs.xdg-desktop-portal-gtk ]; # GTK portal is required for GTK apps.
  };

  services.greetd = {
    enable = true;
    settings.default_session.command = "${pkgs.greetd.tuigreet}/bin/tuigreet --cmd ${pkgs.writeShellScript "sway" ''
      export $(/run/current-system/systemd/lib/systemd/user-environment-generators/30-systemd-environment-d-generator)
      exec sway
    ''}";
  };
}
