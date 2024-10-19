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

  # WAIT: https://github.com/NixOS/nixpkgs/pull/347293
  logseq = pkgs.logseq.override {
    electron = pkgs.electron_27;
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
    kolourpaint libreoffice mpv okular gwenview logseq lyx # Files
    # FIXME: electron-cash fails to build: ModuleNotFoundError: No module named 'imp'
    # FIXME: electrum fails to find protoc, WAIT: https://github.com/NixOS/nixpkgs/pull/349753
    monero-gui
    # steam is enabled system-wide.
    prismlauncher # Games
    telegram-desktop nheko # Messaging
    wf-recorder obs # Recording
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
