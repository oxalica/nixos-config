# Ref: https://github.com/NickCao/flakes/blob/3b03efb676ea602575c916b2b8bc9d9cd13b0d85/nixos/hcloud/iad1/ntfy.nix
{ lib, config, ... }:
let
  inherit (lib) singleton;
  host = "ntfy.oxa.li";
in
{

  services.ntfy-sh = {
    enable = true;
    settings = {
      base-url = "https://${host}";
      listen-http = "";
      listen-unix = "/run/ntfy-sh/ntfy.sock";
      listen-unix-mode = 511; # 0777
      behind-proxy = true;
    };
  };

  systemd.services.ntfy-sh.serviceConfig.RuntimeDirectory = "ntfy-sh";

  services.caddy.settings.apps.http.servers.default.routes = singleton {
    match = singleton { host = singleton host; };
    terminal = true;
    handle = singleton {
      handler = "reverse_proxy";
      upstreams = singleton { dial = "unix/${config.services.ntfy-sh.settings.listen-unix}"; };
    };
  };
}
