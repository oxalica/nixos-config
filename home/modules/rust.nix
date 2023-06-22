{ config, lib, pkgs, inputs, ... }:

let
  # toml
  cargoConfig = ''
    [install]
    root = "${config.home.homeDirectory}/.local"

    [build]
    target-dir = "${config.xdg.cacheHome}/cargo/target"

    [target."${pkgs.rust.toRustTarget pkgs.stdenv.hostPlatform}"]
    linker = "${gcc-lld}"
  '';

  # Seems it reject missing fields.
  # https://github.com/rustsec/rustsec/blob/5058319167c0a86eae7bf25ebc820a8eefeb1c55/cargo-audit/audit.toml.example
  cargoAudit = ''
    [database]
    path = "${config.xdg.cacheHome}/cargo/advisory-db"
    url = "https://github.com/RustSec/advisory-db.git"
    fetch = true
    stale = false
  '';

  # `--no-rosegment` is required for flamegraph
  # https://github.com/flamegraph-rs/flamegraph#cargo-flamegraph
  gcc-lld = pkgs.writeShellScript "gcc-lld" ''
    export PATH="${pkgs.llvmPackages_latest.bintools}/bin''${PATH:+:}$PATH"
    exec ${lib.getExe pkgs.gcc} -fuse-ld=lld -Wl,--no-rosegment "$@"
  '';

in {
  home.packages = with pkgs; with inputs.rust-overlay.packages.${pkgs.system}; [
    (lib.hiPrio rust-nightly.availableComponents.rustfmt)
    (rust.override {
      extensions = [
        "rust-src"
      ];
      targets = [
        "riscv64gc-unknown-linux-gnu"
        "wasm32-unknown-unknown"
      ];
    })

    cargo-audit
    cargo-bloat
    cargo-flamegraph
    cargo-hack
    cargo-insta
    cargo-license
    cargo-machete
    cargo-outdated
    cargo-show-asm
  ];

  # Setup cargo directories.
  # https://doc.rust-lang.org/cargo/commands/cargo.html?highlight=cargo_home#files
  home.sessionVariables."CARGO_HOME" = "${pkgs.runCommandLocal "cargo-home" {
    inherit cargoConfig cargoAudit;
  } ''
    mkdir -p $out
    ln -st $out "${config.xdg.cacheHome}"/cargo/{registry,git}
    ln -st $out "${config.xdg.configHome}"/cargo/credentials.toml
    echo -n "$cargoConfig" >$out/config.toml
    echo -n "$cargoAudit" >$out/audit.toml
  ''}";

  home.activation.setupCargoDirectories = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    $DRY_RUN_CMD mkdir -p "${config.xdg.configHome}"/cargo "${config.xdg.cacheHome}"/cargo/{registry,git}
    if [[ ! -e "${config.xdg.configHome}"/cargo/credentials.toml ]]; then
      $DRY_RUN_CMD touch -a "${config.xdg.configHome}"/cargo/credentials.toml
    fi
  '';
}
