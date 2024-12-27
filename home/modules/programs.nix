{ lib, pkgs, super, my, ... }:

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

  prismlauncher = my.pkgs.prismlauncher-bwrap.override {
    jdks = [ pkgs.jdk21 pkgs.jdk17 ];
  };

in {
  home.packages = with pkgs; [
    # Console
    # FIXME: runzip: configure: error: ZLIB version too old, please install at least v1.1.2
    scc bubblewrap difftastic typos # Random stuff
    xsel wl-clipboard # CLI-Desktop
    beancount my.pkgs.double-entry-generator # Accounting
    tealdeer man-pages # Manual
    sops # Sops

    # GUI
    kolourpaint libreoffice mpv okular gwenview logseq lyx # Files
    # FIXME: electron-cash fails to build: ModuleNotFoundError: No module named 'imp'
    electrum
    monero-gui
    # steam is enabled system-wide.
    prismlauncher # Games
    telegram-desktop nheko # Messaging
    obs # Recording
    my.pkgs.systemd-run-app
    syncplay

    # Dev
    cachix patchelf nixpkgs-review nix-update nix-output-monitor nixfmt-rfc-style # Nix utils
    gcc ghc myPython koka # Compiler & interpreters
    gdb # Debugger
    sqlite-interactive # sqlite
    super.boot.kernelPackages.perf hyperfine
  ];

  programs.feh.enable = true;

  xdg.configFile = let
    gen = path: {
      name = "autostart/${builtins.unsafeDiscardStringContext (builtins.baseNameOf path)}";
      value.source = path;
    };
  in lib.listToAttrs (map gen [
    "${pkgs.firefox}/share/applications/firefox.desktop"
    "${pkgs.telegram-desktop}/share/applications/org.telegram.desktop.desktop"
    "${pkgs.nheko}/share/applications/nheko.desktop"
    "${pkgs.thunderbird}/share/applications/thunderbird.desktop"
  ]);
}
