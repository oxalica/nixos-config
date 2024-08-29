{
  lib,
  buildGoModule,
  fetchFromGitHub,
}:
let
  version = "2.8.4";
  dist = fetchFromGitHub {
    owner = "caddyserver";
    repo = "dist";
    rev = "v${version}";
    hash = "sha256-O4s7PhSUTXoNEIi+zYASx8AgClMC5rs7se863G6w+l0=";
  };
in
buildGoModule {
  pname = "caddy";
  version = "${version}-custom";

  src = fetchFromGitHub {
    owner = "oxalica";
    repo = "caddy";
    rev = "b7a5e89fa55075cb2522a4185e730c7c1f3768b6";
    hash = "sha256-6NqQMA5HKh8ON5CLHw0za6HP8qAnd3VXxW3TqtZ4gvo=";
  };

  vendorHash = "sha256-0hYKuh7VsPcJJJ9x3KvmIfg08Eda9TKk/W0qexY2wpQ=";

  subPackages = [ "cmd/caddy" ];

  ldflags = [
    "-s" "-w"
    "-X github.com/caddyserver/caddy/v2.CustomVersion=${version}"
  ];

  # matches upstream since v2.8.0
  tags = [ "nobadger" ];

  postInstall = ''
    install -Dm644 ${dist}/init/caddy.service ${dist}/init/caddy-api.service -t $out/lib/systemd/system

    substituteInPlace $out/lib/systemd/system/caddy.service \
      --replace-fail "/usr/bin/caddy" "$out/bin/caddy"
    substituteInPlace $out/lib/systemd/system/caddy-api.service \
      --replace-fail "/usr/bin/caddy" "$out/bin/caddy"
  '';

  meta = with lib; {
    homepage = "https://caddyserver.com";
    description = "Fast and extensible multi-platform HTTP/1-2-3 web server with automatic HTTPS";
    license = licenses.asl20;
    mainProgram = "caddy";
  };
}
