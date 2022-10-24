{ pkgs, ... }:
{
  imports = [ ./l10n.nix ];

  programs.sway.enable = true;

  services.udisks2.enable = true; # For `udiskie`.

  xdg.portal.enable = true;
  xdg.portal.extraPortals = [ pkgs.xdg-desktop-portal-gtk ]; # `wlr` is included by `programs.sway`.

  services.greetd = {
    enable = true;
    settings = {
      default_session.command = "${pkgs.greetd.tuigreet}/bin/tuigreet --cmd sway";
    };
  };

  # Disables systemd messages in greeter.
  # Ref: https://github.com/NickCao/flakes/blob/4beaae04bbc89fd377b390266788c05356350808/nixos/local/configuration.nix#L176
  systemd.services.greetd.serviceConfig = {
    ExecStartPre = "${pkgs.util-linux}/bin/kill -SIGRTMIN+21 1";
    ExecStopPost = "${pkgs.util-linux}/bin/kill -SIGRTMIN+20 1";
  };
}
