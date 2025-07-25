{ pkgs, ... }:
{
  imports = [ ../l10n.nix ];

  environment.systemPackages = with pkgs.kdePackages; [
    filelight
    kolourpaint
    okular
    gwenview
    pkgs.qpwgraph
  ];

  environment.variables.NIXOS_OZONE_WL = 1;

  programs = {
    partition-manager.enable = true;
    kdeconnect.enable = true;
  };

  services.desktopManager.plasma6.enable = true;
  services.displayManager.sddm = {
    enable = true;
    wayland.enable = true;
  };

  networking.networkmanager.enable = true;
}
