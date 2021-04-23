{ lib, pkgs, ... }:

let
  /*
  myPython = pkgs.python3.withPackages (ps: with ps; [
    setuptools
    pylint
    numpy
    aiohttp
    pyyaml
    requests
    toml
    matplotlib

    # (opencv4.override {
    #   enableGtk3 = true;
    #   enableFfmpeg = true;
    # })
  ]);
  */

  myPip = pkgs.python3Packages.pip.overrideAttrs (old: {
    postFixup = old.postFixup + ''
      for file in $out/bin/pip*; do
        sed '/PYTHONNOUSERSITE/d' --in-place "$file"
      done
    '';
  });

  myIdris = pkgs.idrisPackages.with-packages (with pkgs.idrisPackages; [
    contrib array
  ]);

in {
  home.packages = with pkgs; map lib.lowPrio [
    # Console
    neofetch htop pv ncdu dnsutils swapview # Stat
    exa fd ripgrep lsof tealdeer jq loop bc gnupg file pwgen rsync # Util
    libarchive runzip # Compression
    trash-cli xsel wl-clipboard # CLI-Desktop
    taskwarrior # Task manager

    # GUI
    kolourpaint vlc libreoffice # Files
    # typora <- usually broken
    # firefox <- in module
    electrum electron-cash monero-gui # Cryptocurrency
    steam minecraft osu-lazer # Games
    tdesktop # Messaging

    # Dev
    man-pages # Man
    cachix patchelf # Utils
    gcc gdb gnumake cmake lld binutils # rust's backtrace-sys requires `ar`
    ghc nodejs idris2 # myIdris <- broken
    python3 myPip # myPython
    nixpkgs-review # nix

    ################
    # Keep from GC #
    ################

    # Dev deps
    pkg-config openssl.dev
  ];
}
