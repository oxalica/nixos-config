{ pkgs, ... }:
{
  imports = [ ./l10n.nix ];

  programs.sway.enable = true;

  # For `udiskie`.
  services.udisks2.enable = true;

  xdg.portal = {
    enable = true;
    extraPortals = [ pkgs.xdg-desktop-portal-gtk ]; # GTK portal is required for GTK apps.
    xdgOpenUsePortal = true;

    wlr = {
      enable = true;
      settings.screencast.max_fps = 10;
    };
  };

  services.greetd = {
    enable = true;
    settings.default_session.command = "${pkgs.greetd.tuigreet}/bin/tuigreet --cmd ${pkgs.writeShellScript "sway" ''
      export $(/run/current-system/systemd/lib/systemd/user-environment-generators/30-systemd-environment-d-generator)
      exec /run/current-system/systemd/bin/systemd-cat --identifier=sway sway
    ''}";
  };
}
