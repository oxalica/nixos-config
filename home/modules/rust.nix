{ config, lib, pkgs, inputs, my, ... }:

let
  inherit (inputs.self.lib) toTOML;

  cargo-machete = my.pkgs.cargo-machete-no-spam;

  cargoConfig = {
    # Ref: https://doc.rust-lang.org/cargo/reference/registry-authentication.html#recommended-configuration
    registry.global-credential-providers = [
      "cargo:token"
      "cargo:libsecret"
    ];

    install.root = "${config.home.homeDirectory}/.local";

    build.target-dir = "${config.xdg.cacheHome}/cargo/target";

    target."${pkgs.hostPlatform.rust.rustcTarget}".linker = gcc-lld;
  };

  # Seems it reject missing fields.
  # https://github.com/rustsec/rustsec/blob/5058319167c0a86eae7bf25ebc820a8eefeb1c55/cargo-audit/audit.toml.example
  cargoAudit = {
    database = {
      path = "${config.xdg.cacheHome}/cargo/advisory-db";
      url = "https://github.com/RustSec/advisory-db.git";
      fetch = true;
      stale = false;
    };
  };

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
        "llvm-tools" # For cargo-llvm-cov
      ];
      targets = [
        "aarch64-apple-darwin"
        "riscv64gc-unknown-linux-gnu"
        "wasm32-unknown-unknown"
        "x86_64-pc-windows-msvc"
      ];
    })

    cargo-audit
    cargo-bloat
    cargo-flamegraph
    cargo-hack
    cargo-insta
    cargo-license
    # FIXME: raw profile version mismatch: Profile uses raw profile format version = 10; expected version = 9
    # cargo-llvm-cov
    cargo-machete
    cargo-outdated
    cargo-show-asm
  ];

  # Setup cargo directories.
  # https://doc.rust-lang.org/cargo/commands/cargo.html?highlight=cargo_home#files
  home.sessionVariables."CARGO_HOME" = "${pkgs.runCommandLocal "cargo-home" {
    cargoConfig = toTOML cargoConfig;
    cargoAudit = toTOML cargoAudit;
  } ''
    mkdir -p $out
    ln -st $out "${config.xdg.cacheHome}"/cargo/{registry,git,.global-cache,.package-cache,.package-cache-mutate}
    ln -st $out "${config.xdg.configHome}"/cargo/credentials.toml
    echo -n "$cargoConfig" >$out/config.toml
    echo -n "$cargoAudit" >$out/audit.toml
  ''}";

  home.activation.setupCargoDirectories = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    run mkdir -p "${config.xdg.configHome}"/cargo "${config.xdg.cacheHome}"/cargo/{registry,git}
    if [[ ! -e "${config.xdg.configHome}"/cargo/credentials.toml ]]; then
      run touch -a "${config.xdg.configHome}"/cargo/credentials.toml
    fi
    for f in .global-cache .package-cache .package-cache-mutate; do
      if [[ ! -e "${config.xdg.cacheHome}"/cargo/"$f" ]]; then
        run touch -a "${config.xdg.cacheHome}"/cargo/"$f"
      fi
    done
  '';
}
