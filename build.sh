#!/usr/bin/env bash
set -e

help() {
  echo "
Usage: $0 [build|test|boot|switch] [target-host] [args...]
    A wrapper for nixos-rebuild.

    Operation is default to be `build` if omitted.
    Target host is default to be localhost if omitted.
    When only building remote configuration, drvs will not be copied to remote.
"
  exit 1
}

op="build"
target=
if [[ "$1" =~ build|test|boot|switch ]]; then
  op="$1"
  shift
fi
if [[ -n "$1" && "$1" != -* ]]; then
  target="$1"
  shift
fi

args=("$op" --flake ".#${target:-$(hostname)}")
if [[ -n "$target" && "$op" != "build" ]]; then
  args+=(
    --use-remote-sudo
    --target-host "$target"
    # Building on remote host is broken currently.
    # See: https://nixos.wiki/wiki/Flakes#Using_nix_flakes_with_NixOS
    --build-host "localhost"
  )
  # Required by `--use-remote-sudo`
  export NIX_SSHOPTS="-t"
fi
args+=("$@")

set -x
exec nixos-rebuild "${args[@]}"
