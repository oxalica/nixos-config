{ lib, pkgs, ... }:

let
  myPython = pkgs.python3.withPackages (ps: with ps; [
    setuptools
    pylint
    numpy
    aiohttp
    pyyaml
    requests
    toml
    matplotlib
  ]);

  myIdris = pkgs.idrisPackages.with-packages (with pkgs.idrisPackages; [
    contrib array
  ]);

in {
  home.packages = with pkgs; map lib.lowPrio [
    # Console
    neofetch htop pv ncdu dnsutils swapview # Stat
    exa fd ripgrep lsof tealdeer jq loop bc file rsync # Util
    gnupg age pwgen # Crypto
    libarchive runzip # Compression
    trash-cli xsel wl-clipboard # CLI-Desktop
    taskwarrior # Task manager
    beancount double-entry-generator

    # GUI
    kolourpaint vlc libreoffice calibre # Files
    # firefox <- in module
    electrum electron-cash monero-gui # Cryptocurrency
    steam minecraft osu-lazer # Games
    tdesktop element-desktop # Messaging

    # Dev
    man-pages # Man
    cachix patchelf # Utils
    gcc gdb gnumake cmake lld binutils # rust's backtrace-sys requires `ar`
    ghc nodejs idris2 myIdris # <- broken
    myPython # python3
    nixpkgs-review # nix
    sqlite-interactive # sqlite
  ];
}
