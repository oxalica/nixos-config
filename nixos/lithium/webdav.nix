{ lib, config, ... }:
let
  inherit (lib) singleton;

  route = "/webdav";
  srvPath = "/srv/webdav";

in
{
  # This requires service restart anyway. Leave it to human.
  sops.secrets.caddy-env = { };
  systemd.services.caddy = {
    serviceConfig = {
      RuntimeDirectory = "caddy";
      ReadWritePaths = singleton srvPath;
      EnvironmentFile = singleton config.sops.secrets.caddy-env.path;
    };
    after = [ "systemd-tmpfiles-setup.service" ];
  };

  # NB. Limit can only be set manually.
  systemd.tmpfiles.settings."webdav" = {
    ${srvPath}.v = {
      group = config.users.groups.caddy.name;
      user = config.users.users.caddy.name;
      mode = "0755";
    };
  };

  services.caddy.settings.apps.http.servers.default.routes = lib.singleton {
    match = singleton {
      host = singleton config.networking.fqdn;
      path = singleton "${route}/*";
    };
    handle = [
      {
        handler = "authentication";
        providers.http_basic.accounts = singleton {
          username = "{env.WEBDAV_USERNAME}";
          password = "{env.WEBDAV_PASSWORD}";
        };
      }
      {
        handler = "webdav";
        root = srvPath;
        # Workaround: prefix makes HEAD fail with 405 (Method Not Allowed)
        # See: https://github.com/mholt/caddy-webdav/issues/19
        # prefix = route;
      }
    ];
  };
}
