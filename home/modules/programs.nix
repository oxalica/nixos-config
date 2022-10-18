{ lib, pkgs, my, ... }:

let
  myPython = pkgs.python3.withPackages (ps: with ps; [
    aiohttp
    numpy
    pylint
    pyyaml
    requests
    toml
  ]);

in {
  home.packages = with pkgs; map lib.lowPrio [
    # Console
    runzip scc bubblewrap # Random stuff
    xsel wl-clipboard # CLI-Desktop
    beancount my.pkgs.double-entry-generator # Accounting
    tealdeer man-pages # Manual
    sops # Sops

    # GUI
    kolourpaint libreoffice mpv evince # Files
    electrum electron-cash monero-gui # Cryptocurrency
    /* steam <- enabled system-wide */ # Games
    tdesktop nheko # Messaging
    simplescreenrecorder obs-studio # Recording

    # Dev
    cachix patchelf nixpkgs-review # Nix utils
    gcc ghc myPython # Compiler & interpreters
    sqlite-interactive # sqlite
  ];

  programs.feh.enable = true;
}
