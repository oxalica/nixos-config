{ pkgs, super, my, ... }:

let
  myPython = pkgs.python3.withPackages (ps: with ps; [
    aiohttp
    numpy
    pylint
    pyyaml
    requests
    toml
  ]);

  obs = pkgs.wrapOBS {
    plugins = with pkgs.obs-studio-plugins; [
      obs-pipewire-audio-capture
      obs-vaapi
    ];
  };

in {
  home.packages = with pkgs; [
    # Console
    runzip scc bubblewrap difftastic typos # Random stuff
    xsel wl-clipboard # CLI-Desktop
    beancount my.pkgs.double-entry-generator # Accounting
    tealdeer man-pages # Manual
    sops # Sops

    # GUI
    kolourpaint libreoffice mpv okular gwenview obsidian logseq lyx # Files
    electrum electron-cash monero-gui # Cryptocurrency
    prismlauncher /* steam <- enabled system-wide */ # Games
    telegram-desktop nheko # Messaging
    wf-recorder obs # Recording
    my.pkgs.systemd-run-app

    # Dev
    cachix patchelf nixpkgs-review nix-update nix-output-monitor # Nix utils
    gcc ghc myPython koka # Compiler & interpreters
    gdb # Debugger
    sqlite-interactive # sqlite
    super.boot.kernelPackages.perf hyperfine
  ];

  programs.feh.enable = true;
}
