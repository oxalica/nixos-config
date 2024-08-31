{
  lib,
  pkgs,
  inputs,
  ...
}:
let
  inherit (lib) singleton;
  host = "blah.oxa.li";
  port = 8080;

in
{
  environment.systemPackages = with pkgs; [ sqlite-interactive ];

  services.blahd = {
    enable = true;
    settings = {
      server.listen = "localhost:${toString port}";
      server.base_url = "http://${host}/api";
    };
  };

  # NB. Limit can only be set manually.
  systemd.tmpfiles.settings."blahd"."/var/lib/private/blahd".v = { };

  systemd.services.blahd = {
    after = [ "systemd-tmpfiles-setup.service" ];
    serviceConfig = {
      MemoryMax = "256M";
      MemorySwapMax = "0";
    };
  };

  services.caddy.settings.apps.http.servers.default.routes = singleton {
    match = singleton {
      host = singleton host;
    };
    terminal = true;
    handle = singleton {
      handler = "subroute";
      routes = [
        {
          handle = singleton {
            handler = "encode";
            encodings = {
              zstd = { };
              gzip = { };
            };
            prefer = [
              "zstd"
              "gzip"
            ];
          };
        }
        {
          match = singleton { path = singleton "/"; };
          terminal = true;
          handle = singleton {
            handler = "static_response";
            status_code = 302;
            headers.Location = singleton "https://${host}/testing/";
          };
        }
        {
          match = singleton { path = singleton "/testing/default.json"; };
          terminal = true;
          handle = singleton {
            handler = "static_response";
            status_code = 200;
            headers.Content-Type = singleton "application/json";
            body = builtins.toJSON {
              server_url = "https://${host}/api";
              room = "00000000-0000-0000-0000-000000000000";
            };
          };
        }
        {
          match = singleton { path = singleton "/testing/*"; };
          terminal = true;
          handle = [
            {
              handler = "rewrite";
              strip_path_prefix = "/testing";
            }
            {
              handler = "rewrite";
              path_regexp = singleton {
                find = "^/$";
                replace = "/index.html";
              };
            }
            {
              handler = "file_server";
              # Force re-dump a subdirectory without copying the whole flake input.
              root = builtins.filterSource (path: type: true) "${inputs.blahrs}/pages";
            }
          ];
        }
        {
          match = singleton { path = singleton "/api/*"; };
          terminal = true;
          handle = [
            {
              handler = "rewrite";
              strip_path_prefix = "/api";
            }
            {
              handler = "reverse_proxy";
              upstreams = singleton { dial = "localhost:${toString port}"; };
            }
          ];
        }
      ];
    };
  };
}
