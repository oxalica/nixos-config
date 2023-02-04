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
  home.packages = with pkgs; [
    # Console
    runzip scc bubblewrap difftastic # Random stuff
    xsel wl-clipboard # CLI-Desktop
    beancount my.pkgs.double-entry-generator # Accounting
    tealdeer man-pages # Manual
    sops # Sops

    # GUI
    kolourpaint libreoffice mpv okular # Files
    electrum electron-cash monero-gui # Cryptocurrency
    (prismlauncher.override { jdks = [ openjdk ]; }) /* steam <- enabled system-wide */ # Games
    tdesktop my.pkgs.nheko-fix # Messaging
    wf-recorder obs-studio # Recording

    # Dev
    cachix patchelf nixpkgs-review nix-update nix-output-monitor # Nix utils
    gcc ghc myPython # Compiler & interpreters
    gdb # Debugger
    sqlite-interactive # sqlite
  ];

  programs.feh.enable = true;
}
