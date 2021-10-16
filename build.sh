#!/usr/bin/env bash
set -e

help() {
  echo "
Usage:
  $0 [target-host] [args...]
  $0 <build|test|boot|switch> [target-host] [args...]
  $0 [target-host] <dry-build|build|test|boot|switch> [args...]
    A wrapper for nixos-rebuild.

    Operation is default to be `build` if omitted.
    Target host is default to be localhost if omitted.
    When only building remote configuration, drvs will not be copied to remote.
"
  exit 1
}

op=
target=
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
            if [[ -n "$target" ]]; then
                echo "Multiple target: $target, $1"
                exit 1
            fi
            target="$1"
            shift
            ;;
    esac
done

op="${op:-build}"

args=()
if [[ -z "$target" && "$op" != *"build" ]]; then
  args+=(sudo)
fi

args+=(nixos-rebuild "$op" --flake ".#${target:-$(hostname)}")
if [[ -n "$target" && "$op" != "build" ]]; then
  args+=(
    --use-remote-sudo
    --target-host "$target"
  )
  # Required by `--use-remote-sudo`
  export NIX_SSHOPTS="-t"
fi
args+=("$@")

set -x
exec "${args[@]}"
