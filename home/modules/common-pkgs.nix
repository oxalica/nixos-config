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
    runzip # Random stuff
    trash-cli xsel wl-clipboard # CLI-Desktop
    beancount double-entry-generator # Accounting
    tealdeer man-pages # Manual
    sops ssh-to-age # Sops

    # GUI
    kolourpaint vlc libreoffice calibre # Files
    electrum electron-cash monero-gui # Cryptocurrency
    steam minecraft # Games
    tdesktop element-desktop # Messaging
    simplescreenrecorder obs-studio # Recording

    # Dev
    cachix patchelf nixpkgs-review nixpkgs-fmt nixfmt # Nix utils
    gcc ghc idris2 idris myPython # Compiler & interpreters
    gdb gnumake cmake lld binutils # Tools
    sqlite-interactive # sqlite
  ];
}
