{ lib, config, pkgs, my, ... }:
let
  inherit (lib) singleton;
  logDir = "/var/lib/caddy/logs";
in
{
  imports = [
    ../modules/vultr-common.nix

    ./blah.nix
    ./ntfy.nix
    ./webdav.nix
  ];

  # TODO: Investigate if 6.12 gets the memory corruption issue fixed.
  # When bumping, add squota!
  boot.kernelPackages = pkgs.linuxPackages_6_6;

  swapDevices = [
    {
      device = "/var/swapfile";
      size = 1024;
    }
  ];

  # `echo -n 'nixos-repart-seed/lithium' | sha256sum | head -c32`
  image.repart.seed = "bedd7526-d0f7-6013-a6b0-986b264af135";

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
            status_code = 404;
            body = "404";
          };
        });
        logs.default_logger_name = "default";
      };
      logging.logs.default = {
        writer = {
          output = "file";
          filename = "${logDir}/log";
        };
        encoder.format = "json";
        include = [ "http.log.access.default" ];
      };
    };

    adapter = null;
    configFile = let
      format = pkgs.formats.json { };
    in
      (format.generate "caddy.json" config.services.caddy.settings).overrideAttrs (old: {
        # - Validation will access env vars.
        #   From: https://github.com/caddyserver/caddy/blob/c050a37e1c3228708a6716c8971361134243e941/modules/caddyhttp/caddyauth/hashes.go#L56
        # - Avoid using `/var/lib` which is forbidden in sandbox.
        buildCommand = old.buildCommand + ''
          export WEBDAV_USERNAME=for-validate
          export WEBDAV_PASSWORD='$2a$14$X3ulqf/iGxnf1k6oMZ.RZeJUoqI9PX2PM4rS5lkIKJXduLGXGPrt6'
          ${lib.getExe pkgs.buildPackages.gnused} -E "s_/var/lib/_$(pwd)/var/lib/_g" $out >./config.json
          ${lib.getExe config.services.caddy.package} validate --config ./config.json
        '';
      });

  };

  systemd.tmpfiles.settings."caddy-logs" = {
    ${logDir}.d = {
      group = config.users.groups.caddy.name;
      user = config.users.users.caddy.name;
      mode = "0755";
    };
  };

  system.stateVersion = "24.11";
}
