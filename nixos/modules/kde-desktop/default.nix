{ pkgs, my, ... }:
{
  imports = [ ../l10n.nix ];

  environment.systemPackages = with pkgs.kdePackages; [
    filelight
    my.pkgs.bismuth-fix-5-27
  ];

  programs = {
    partition-manager.enable = true;
    kdeconnect.enable = true;
  };

  services.desktopManager.plasma6.enable = true;
  services.xserver = {
    enable = true;
    xkb.layout = "us";
    displayManager.sddm.enable = true;
  };

  networking.networkmanager.enable = true;
}
