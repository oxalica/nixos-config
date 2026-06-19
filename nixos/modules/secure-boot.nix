# https://github.com/nix-community/lanzaboote/blob/master/docs/QUICK_START.md
{ pkgs, inputs, ... }:
{
  imports = [
    inputs.lanzaboote.nixosModules.lanzaboote
  ];

  environment.systemPackages = [
    pkgs.sbctl
  ];

  # Lanzaboote currently replaces the systemd-boot module.
  # This setting is usually set to true in configuration.nix
  # generated at installation time. So we force it to false
  # for now.
  boot.loader.systemd-boot.enable = false;

  boot.lanzaboote = {
    enable = true;
    # See: https://github.com/nix-community/lanzaboote/issues/413
    pkiBundle = "/var/lib/sbctl";
  };
}
