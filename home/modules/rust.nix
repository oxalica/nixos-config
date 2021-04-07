{ config, lib, pkgs, ... }:

let
  defaultMaxDays = 15;

  # Global target
  targetDir = ".cargo/target";

  rust-stable = pkgs.latest.rustChannels.stable.default.override {
    extensions = [
      "rust-src"
    ];
    targets = [
      "x86_64-unknown-linux-musl"
      "riscv64gc-unknown-linux-gnu"
    ];
  };

in {
  # home.file.".cargo/config".source = config.lib.file.mkOutOfStoreSymlink "../.config/cargo";

  home.packages = [
    rust-stable
  ] ++ (with pkgs; [
    cargo-edit
    cargo-flamegraph
    cargo-insta
    cargo-license
    cargo-watch
  ]);

  home.file.".cargo/config".source = let
    triple = pkgs.stdenv.hostPlatform.config;

    cargoConfig = {
      build.target-dir = "${targetDir}";
      # target."${triple}".linker = linker;
    };

    rust-lld-wrapper = pkgs.writeShellScriptBin "ld.lld" ''
      set -e
      exec -a ld.lld "$(rustc --print sysroot)/lib/rustlib/${triple}/bin/rust-lld" "$@"
    '';
    linker = pkgs.writeShellScript "rust-ld-wrapper" ''
      export PATH="${rust-lld-wrapper}/bin''${PATH:+:}$PATH"
      exec ${pkgs.gcc}/bin/gcc -fuse-ld=lld "$@"
    '';

  in pkgs.runCommandNoCC "cargo-config" {
    preferLocalBuild = true;
    nativeBuildInputs = [ pkgs.remarshal ];
    value = builtins.toJSON cargoConfig;
    passAsFile = [ "value" ];
  } ''
    json2toml "$valuePath" "$out"
  '';

  systemd.user.services."cargo-clean-target" = {
    Unit.Description = "Clean global cargo target directory";
    Service.ExecStart = let
      cargo-clean-target = pkgs.writeShellScriptBin "cargo-clean-target" ''
        set -e
        PATH="$PATH:${pkgs.coreutils}/bin:${pkgs.findutils}/bin"
        targetPath="$HOME/${targetDir}"
        days="${toString defaultMaxDays}"

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
      OnCalendar = "Sun";
      Persistent = true;
    };
    Install.WantedBy = [ "timers.target" ];
  };
}
