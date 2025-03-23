{ lib, pkgs, super, my, inputs, ... }:

let
  myPython = pkgs.python3.withPackages (ps: with ps; [
    aiohttp
    numpy
    pylint
    pyyaml
    requests
    toml
    z3
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

  logseq = (import inputs.nixpkgs-logseq {
    inherit (pkgs) system;
    config.permittedInsecurePackages = [ "electron-27.3.11" ];
  }).logseq;

in {
  home.packages = with pkgs; [
    # Console
    scc bubblewrap difftastic typos # Random stuff
    xsel wl-clipboard # CLI-Desktop
    beancount my.pkgs.double-entry-generator # Accounting
    tealdeer man-pages # Manual
    sops # Sops

    # GUI
    libreoffice mpv logseq lyx # Files
    electron-cash
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
