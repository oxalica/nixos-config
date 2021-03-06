{ config, lib, pkgs, ... }:

let
  defaultMaxDays = 15;

  # Global target
  targetDir = "${home}/.cache/cargo/target";

  home = config.home.homeDirectory;

  cargoConfig = ''
    [install]
    root = "${home}/.local"

    [build]
    target-dir = "${targetDir}"

    ${lib.optionalString enableLld ''
      [target."${rustHostTarget}"]
      linker = "${lld-linker}"
    ''}
  '';

  enableLld = true;
  rustHostTarget = pkgs.rust.toRustTarget pkgs.stdenv.hostPlatform;
  lld-wrapper = pkgs.wrapBintoolsWith {
    bintools = pkgs.writeShellScriptBin "ld.lld" ''
      set -e
      exec -a ld.lld "$(rustc --print sysroot)/lib/rustlib/${rustHostTarget}/bin/rust-lld" "$@"
    '';
  };
  lld-linker = pkgs.writeShellScript "lld-linker" ''
    lld="$(rustc --print sysroot)/lib/rustlib/${rustHostTarget}/bin/rust-lld" || true
    if [[ -e "$lld" && -z "$RUST_NO_LLD" ]]; then
      export PATH="${lld-wrapper}/bin''${PATH:+:}$PATH"
      exec ${pkgs.gcc}/bin/gcc -fuse-ld=lld "$@"
    else
      exec ${pkgs.gcc}/bin/gcc "$@"
    fi
  '';

in {
  home.packages = with pkgs; [
    (rust-bin.stable.latest.default.override {
      extensions = [
        "rust-src"
      ];
      targets = [
        "x86_64-unknown-linux-musl"
        "riscv64gc-unknown-linux-gnu"
      ];
    })

    cargo-edit
    cargo-flamegraph
    cargo-insta
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

  # Force enable incremental build to save huge amount of time.
  #
  # Annonce: https://blog.rust-lang.org/2021/05/10/Rust-1.52.1.html#short-term-plan
  # Issue: https://github.com/rust-lang/rust/issues/84970
  home.sessionVariables."RUSTC_FORCE_INCREMENTAL" = "1";

  home.activation.setupCargoDirectories = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    $DRY_RUN_CMD mkdir -p "${home}"/{.config/cargo,.cache/cargo/{registry,git}}
    $DRY_RUN_CMD touch -a "${home}"/.config/cargo/credentials.toml
  '';

  /*
  systemd.user.services."cargo-clean-target" = {
    Unit.Description = "Clean global cargo target directory";
    Service.ExecStart = let
      cargo-clean-target = pkgs.writeShellScriptBin "cargo-clean-target" ''
        set -e
        PATH="$PATH:${pkgs.coreutils}/bin:${pkgs.findutils}/bin"
        targetPath="${targetDir}"
        days="${toString defaultMaxDays}"

        [[ -d "$targetPath" ]] || exit 0

        countSize() {
          ret=$(du -P -sb "$1")
          echo ''${ret%%$(echo -ne '\t')*}
        }

        before=$(countSize "$targetPath")
        echo "Before: $((before / 1024 / 1024)) MiB ($before bytes)"

        echo "Cleaning $targetPath not accessed in recent $days days ..."
        find "$targetPath" \
          -depth \
          -ignore_readdir_race \
          \( -atime "+$days" -o -type d -empty \) \
          -delete

        after=$(countSize "$targetPath")
        echo "After: $((after / 1024 / 1024)) MiB ($after bytes)"
        echo "Cleaned: $((($before - $after) / 1024 / 1024)) MiB ($(($before - $after)) bytes)"
      '';
    in "${cargo-clean-target}/bin/cargo-clean-target";
  };
  systemd.user.timers."cargo-clean-target" = {
    Timer = {
      OnCalendar = "Mon";
      Persistent = true;
    };
    Install.WantedBy = [ "timers.target" ];
  };
  */
}
