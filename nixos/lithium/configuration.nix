{ lib, pkgs, my, ... }:
let
  inherit (lib) singleton;
in
{
  imports = [
    ../modules/console-env.nix
    ../modules/nix-common.nix
    ../modules/vultr-common.nix

    ./webdav.nix
  ];

  documentation.enable = false;

  boot.kernelPackages =
    lib.warnIf
      (pkgs.linuxPackages.kernelAtLeast "6.7")
      "LTS kernel already support squota"
      pkgs.linuxPackages_6_10;

  fileSystems."/" = lib.mkForce {
    device = "/dev/disk/by-label/nixos";
    fsType = "btrfs";
    options = [ "noatime" "space_cache=v2" "compress=zstd" ];
  };

  swapDevices = [
    {
      device = "/var/swapfile";
      size = 1024;
    }
  ];

  environment.systemPackages = with pkgs; [
    git
  ];

  networking.domain = "node.oxa.li";

  # Ref: https://github.com/NickCao/flakes/blob/f38cc7f87108dc1c08cd6830dcf0bf2c13539f04/modules/caddy.nix#L26
  services.caddy = {
    enable = true;
    package = my.pkgs.caddy-custom;
    settings = {
      admin = {
        listen = "unix//run/caddy/admin.sock";
        config.persist = false;
      };
      apps.http.grace_period = "1s";
      apps.http.servers.default = {
        listen = [ ":443" ];
        routes = lib.mkAfter (singleton {
          handle = singleton {
            handler = "static_response";
            status_code = "404";
          };
        });
      };
    };
  };

  system.stateVersion = "24.05";
}
