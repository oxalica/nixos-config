# This file was generated by nvfetcher, please do not modify it manually.
{ fetchgit, fetchurl, fetchFromGitHub }:
{
  btrfs_map_physical = {
    pname = "btrfs_map_physical";
    version = "49aec6b85d8457fa25b5d8f6c2afb3dd4592401a";
    src = fetchurl {
      url = "https://raw.githubusercontent.com/osandov/osandov-linux/49aec6b85d8457fa25b5d8f6c2afb3dd4592401a/scripts/btrfs_map_physical.c";
      sha256 = "sha256-KyAIWrSaUJEfpFh7R3u/VYYaC8fQxoCTWb6jlayMufw=";
    };
  };
  colors = {
    pname = "colors";
    version = "94d8b2be62657e96488038b0e547e3009ed87d40";
    src = fetchurl {
      url = "https://gist.githubusercontent.com/lilydjwg/fdeaf79e921c2f413f44b6f613f6ad53/raw/94d8b2be62657e96488038b0e547e3009ed87d40/colors.py";
      sha256 = "sha256-l/RTPZp2v7Y4ffJRT5Fy5Z3TDB4dvWfE7wqMbquXdJA=";
    };
  };
  double-entry-generator = {
    pname = "double-entry-generator";
    version = "v1.6.0";
    src = fetchFromGitHub ({
      owner = "deb-sig";
      repo = "double-entry-generator";
      rev = "v1.6.0";
      fetchSubmodules = false;
      sha256 = "sha256-qiQOkWTVkTTD2wjosMzAlBKZjijdJL56++NghEvTAWY=";
    });
    vendorHash = "sha256-yA4ax81rWHTfXj0+8ds4OweUickHtR8QZsgJyulW2j4=";
  };
  rawmv = {
    pname = "rawmv";
    version = "v0.2.0";
    src = fetchFromGitHub ({
      owner = "oxalica";
      repo = "rawmv";
      rev = "v0.2.0";
      fetchSubmodules = false;
      sha256 = "sha256-cH6NahMzifs5OOSE0nBY4kDr+xPtqcOuVghP/g5JTsc=";
    });
    cargoHash = "sha256-sEpvRgvxcH7qnUZ5S3khXdJucmhZ8tl/tIVfpQxV56Y=";
  };
  rime_latex = {
    pname = "rime_latex";
    version = "d484bf6f8d4e4ccdb06c691fa4feeefd1fe58d1c";
    src = fetchFromGitHub ({
      owner = "shenlebantongying";
      repo = "rime_latex";
      rev = "d484bf6f8d4e4ccdb06c691fa4feeefd1fe58d1c";
      fetchSubmodules = false;
      sha256 = "sha256-8k6CCFlXaNKejs6+jusMD4W94IsMZGclL7vFcUy/h+Y=";
    });
  };
  sway-systemd = {
    pname = "sway-systemd";
    version = "v0.2.2";
    src = fetchFromGitHub ({
      owner = "alebastr";
      repo = "sway-systemd";
      rev = "v0.2.2";
      fetchSubmodules = false;
      sha256 = "sha256-S10x6A1RaD1msIw9pWXpBHFKKyWfsaEGbAZo2SU3CtI=";
    });
  };
  sway-unwrapped = {
    pname = "sway-unwrapped";
    version = "1.8-rc2";
    src = fetchFromGitHub ({
      owner = "swaywm";
      repo = "sway";
      rev = "1.8-rc2";
      fetchSubmodules = false;
      sha256 = "sha256-a1ypTSWcyOk1s97ogrVFrKfhRKfkHzbAqN5smoO36Wg=";
    });
  };
  swaylock-effects = {
    pname = "swaylock-effects";
    version = "v1.6.10";
    src = fetchFromGitHub ({
      owner = "jirutka";
      repo = "swaylock-effects";
      rev = "v1.6.10";
      fetchSubmodules = false;
      sha256 = "sha256-VkyH9XN/pR1UY/liG5ygDHp+ymdqCPeWHyU7/teJGbU=";
    });
  };
  tree-sitter-nix = {
    pname = "tree-sitter-nix";
    version = "add8eb3050a0974c1854df419c192fa4f359bcb0";
    src = fetchFromGitHub ({
      owner = "oxalica";
      repo = "tree-sitter-nix";
      rev = "add8eb3050a0974c1854df419c192fa4f359bcb0";
      fetchSubmodules = false;
      sha256 = "sha256-x2Kq7t0p5AOKIHtEUHMIC6emZNoF9GE2FdKbjEfUp0E=";
    });
  };
}
