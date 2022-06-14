{ lib, pkgs, ... }:

let
  myPython = pkgs.python3.withPackages (ps: with ps; [
    pylint
    numpy
    pyyaml
    requests
    toml
  ]);

in {
  home.packages = with pkgs; map lib.lowPrio [
    # Console
    runzip scc # Random stuff
    xsel wl-clipboard # CLI-Desktop
    beancount double-entry-generator # Accounting
    tealdeer man-pages # Manual
    sops # Sops

    # GUI
    kolourpaint vlc libreoffice  # Files
    electrum electron-cash monero-gui # Cryptocurrency
    steam polymc # Games
    tdesktop element-desktop # Messaging
    simplescreenrecorder obs-studio # Recording

    # Dev
    cachix patchelf nixpkgs-review nixpkgs-fmt nixfmt # Nix utils
    gcc ghc idris2 myPython # Compiler & interpreters
    gdb gnumake cmake lld binutils # Tools
    sqlite-interactive # sqlite
  ];

  programs.feh.enable = true;
}
