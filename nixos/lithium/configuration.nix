{ lib, config, pkgs, my, ... }:
let
  inherit (lib) singleton;
in
{
  imports = [
    ../modules/vultr-common.nix

    ./blah.nix
    ./webdav.nix
  ];

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

    adapter = null;
    configFile = let
      format = pkgs.formats.json { };
    in
      (format.generate "caddy.json" config.services.caddy.settings).overrideAttrs (old: {
        # Validation will access env vars.
        # From: https://github.com/caddyserver/caddy/blob/c050a37e1c3228708a6716c8971361134243e941/modules/caddyhttp/caddyauth/hashes.go#L56
        buildCommand = old.buildCommand + ''
          export WEBDAV_USERNAME=for-validate
          export WEBDAV_PASSWORD='$2a$14$X3ulqf/iGxnf1k6oMZ.RZeJUoqI9PX2PM4rS5lkIKJXduLGXGPrt6'
          ${lib.getExe config.services.caddy.package} validate --config $out
        '';
      });

  };

  system.stateVersion = "24.05";
}
