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
    neofetch htop pv iperf3 loc nmap ncdu dnsutils swapview # Stat
    exa fd ripgrep lsof tealdeer jq loop bc gnupg file pwgen rsync # Util
    libarchive runzip # Compression
    trash-cli xsel # X-GUI
    # nix-prefetch-git nix-prefetch-github # Nix

    # GUI
    kolourpaint vlc libreoffice typora # Files
    firefox # Browser
    electrum go-ethereum # Cryptocurrency
    steam minecraft osu-lazer obs-studio # Games
    tdesktop hexchat # IM

    # Dev
    cachix patchelf sqlite-interactive # Utils
    gcc gdb gnumake lld binutils # rust's backtrace-sys requires `ar`
    ghc nodejs idris2 # myIdris <- broken
    python3 myPip # myPython

    ################
    # Keep from GC #
    ################

    # Dev deps
    pkg-config
    gtk3
    openssl.dev
    # (opencv4.override {
    #   enableGtk3 = true;
    #   enableFfmpeg = true;
    # })

    # For update scripts
    (lib.lowPrio rustPlatform.rust.rustc)
    (lib.lowPrio rustPlatform.rust.cargo)
    carnix
    nodePackages.node2nix
    vgo2nix
    dotnet-sdk_3
  ];
}
