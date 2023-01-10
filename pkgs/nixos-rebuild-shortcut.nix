{ lib, stdenv, runCommand, runtimeShell, hostname, coreutils, ... }:
runCommand "nixos-rebuild-shortcut" {
  preferLocalBuild = true;
  allowSubstitutes = false;

  # bash
  text = ''
    #!${runtimeShell}
    export PATH="${lib.makeBinPath [ hostname coreutils ]}''${PATH:+:}$PATH"

    localname="$(hostname)"
    name="$localname"
    action=build
    if [[ "''${1-}" == @* ]]; then
      name="''${1:1}"
      shift
    fi
    if [[ -n "''${1-}" ]]; then
      action="$1"
      shift
    fi

    if [[ "$action" =~ (boot|switch|test) && "$(id -u)" != 0 ]]; then
      echo "'$action' expects root permission" >&2
      exit 1
    fi

    cmd=(nixos-rebuild "$action" --flake ".#$name")
    if [[ "$name" != "$localname" && "$action" != *build* ]]; then
      cmd+=(
        --use-remote-sudo
        --target-host "$name"
      )
      # Required by `--use-remote-sudo`
      export NIX_SSHOPTS="-t"
    fi

    cmd+=("$@")

    set -x
    exec "''${cmd[@]}"
  '';
} ''
  mkdir -p $out/bin
  cat >$out/bin/nixos <<<"$text"
  chmod +x $out/bin/nixos
  ${stdenv.shellDryRun} $out/bin/nixos
''
