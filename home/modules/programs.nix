{ pkgs, my, ... }:

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

  prismlauncher = pkgs.prismlauncher.override {
    glfw = my.pkgs.glfw-minecraft-wayland;
  };

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
    prismlauncher /* steam <- enabled system-wide */ # Games
    tdesktop nheko # Messaging
    wf-recorder obs # Recording

    # Dev
    cachix patchelf nixpkgs-review nix-update nix-output-monitor # Nix utils
    gcc ghc myPython # Compiler & interpreters
    gdb # Debugger
    sqlite-interactive # sqlite
  ];

  programs.feh.enable = true;
}
