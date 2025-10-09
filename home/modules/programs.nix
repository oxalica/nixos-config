{
  lib,
  pkgs,
  my,
  ...
}:

let
  myPython = pkgs.python3.withPackages (
    ps: with ps; [
      aiohttp
      numpy
      pylint
      pyyaml
      requests
      toml
      z3
    ]
  );

  obs = pkgs.wrapOBS {
    plugins = with pkgs.obs-studio-plugins; [
      obs-pipewire-audio-capture
      obs-vaapi
    ];
  };

  prismlauncher = my.pkgs.prismlauncher-bwrap.override {
    jdks = [
      pkgs.jdk21
      pkgs.jdk17
    ];
  };

in
{
  home.packages = with pkgs; [
    # Console
    scc
    bubblewrap
    difftastic
    typos # Random stuff
    xsel
    wl-clipboard # CLI-Desktop
    beancount # Accounting
    tealdeer
    man-pages # Manual
    sops # Sops

    # GUI
    # FIXME: libreoffice
    mpv
    logseq
    lyx
    dwarfs # Files
    electron-cash
    electrum
    monero-gui
    # steam is enabled system-wide.
    prismlauncher # Games
    telegram-desktop
    nheko # Messaging
    obs # Recording
    my.pkgs.systemd-run-app
    syncplay
    restic

    # Dev
    cachix
    patchelf
    nixpkgs-review
    nix-update
    nix-output-monitor
    nixfmt-rfc-style # Nix utils
    gcc
    ghc
    myPython
    koka # Compiler & interpreters
    gdb # Debugger
    sqlite-interactive # sqlite
    perf
    hyperfine
  ];

  programs.feh.enable = true;

  xdg.configFile =
    let
      gen = path: {
        name = "autostart/${builtins.unsafeDiscardStringContext (builtins.baseNameOf path)}";
        value.source = path;
      };
    in
    lib.listToAttrs (
      map gen [
        "${pkgs.firefox}/share/applications/firefox.desktop"
        "${pkgs.telegram-desktop}/share/applications/org.telegram.desktop.desktop"
        "${pkgs.nheko}/share/applications/nheko.desktop"
        "${pkgs.thunderbird}/share/applications/thunderbird.desktop"
      ]
    );
}
