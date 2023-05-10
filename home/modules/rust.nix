{ config, lib, pkgs, inputs, ... }:

let
  # Global target
  targetDir = "${home}/.cache/cargo/target";

  home = config.home.homeDirectory;

  # toml
  cargoConfig = ''
    [install]
    root = "${home}/.local"

    [build]
    target-dir = "${targetDir}"

    [target."${pkgs.rust.toRustTarget pkgs.stdenv.hostPlatform}"]
    linker = "${gcc-lld}"
  '';

  # `--no-rosegment` is required for flamegraph
  # https://github.com/flamegraph-rs/flamegraph#cargo-flamegraph
  gcc-lld = pkgs.writeShellScript "gcc-lld" ''
    export PATH="${pkgs.llvmPackages_latest.bintools}/bin''${PATH:+:}$PATH"
    exec ${pkgs.gcc}/bin/gcc -fuse-ld=lld -Wl,--no-rosegment "$@"
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
    cargo-insta
    cargo-license
    cargo-machete
    cargo-outdated
    cargo-show-asm
  ];

  # Setup cargo directories.
  # https://doc.rust-lang.org/cargo/commands/cargo.html?highlight=cargo_home#files
  home.sessionVariables."CARGO_HOME" = "${pkgs.runCommandLocal "cargo-home" {
    inherit cargoConfig;
  } ''
    mkdir -p $out
    ln -st $out "${home}"/.cache/cargo/{registry,git}
    ln -st $out "${home}"/.config/cargo/credentials.toml
    echo -n "$cargoConfig" >$out/config.toml
  ''}";

  home.activation.setupCargoDirectories = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    $DRY_RUN_CMD mkdir -p "${home}"/{.config/cargo,.cache/cargo/{registry,git}}
    $DRY_RUN_CMD touch -a "${home}"/.config/cargo/credentials.toml
  '';
}
