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
    runzip # Random stuff
    trash-cli xsel wl-clipboard # CLI-Desktop
    beancount double-entry-generator # Accounting
    tealdeer man-pages # Manual

    # GUI
    kolourpaint vlc libreoffice calibre # Files
    electrum electron-cash monero-gui # Cryptocurrency
    steam minecraft osu-lazer # Games
    tdesktop element-desktop # Messaging
    simplescreenrecorder obs-studio # Recording

    # Dev
    cachix patchelf # Utils
    gcc ghc nodejs idris2 myIdris myPython # Compiler & interpreters
    gdb gnumake cmake lld binutils # Tools
    nixpkgs-review nixpkgs-fmt nixfmt # nix
    sqlite-interactive # sqlite
  ];
}
