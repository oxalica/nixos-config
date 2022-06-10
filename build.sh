#!/usr/bin/env bash
set -e

help() {
  echo "
Usage:
  $0 [config-name] [args...]
  $0 <build|test|boot|switch> [config-name] [args...]
  $0 [config-name] <dry-build|build|test|boot|switch> [args...]
    A wrapper for nixos-rebuild.

    Operation is default to be `build` if omitted.
    Target host is default to be localhost if omitted.
    When only building remote configuration, drvs will not be copied to remote.
"
  exit 1
}

op=
name=
while [[ $# -ne 0 ]]; do
    case "$1" in
        dry-build|build|test|boot|switch)
            if [[ -n "$op" ]]; then
                echo "Multiple operation: $op, $1"
                exit 1
            fi
            op="$1"
            shift
            ;;
        -*|"")
            break
            ;;
        *)
            if [[ -n "$name" ]]; then
                echo "Multiple config name: $name, $1"
                exit 1
            fi
            name="$1"
            shift
            ;;
    esac
done

op="${op:-build}"

args=()
if [[ -z "$name" && "$op" != *"build" ]]; then
  args+=(sudo)
fi
name="${name:-$(hostname)}"

targetHost="$(nix eval --raw .#nixosConfigurations.$name.config.networking.hostName)"

args+=(nixos-rebuild "$op" --flake ".#$name")
if [[ "$name" != "$(hostname)" && "$op" != "build" ]]; then
  args+=(
    --use-remote-sudo
    --target-host "$targetHost"
  )
  # Required by `--use-remote-sudo`
  export NIX_SSHOPTS="-t"
fi

args+=("$@")

set -x
exec "${args[@]}"
