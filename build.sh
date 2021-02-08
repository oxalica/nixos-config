#!/usr/bin/env bash
set -e

help() {
  echo "
Usage:
  $0 [target-host] [args...]
  $0 <build|test|boot|switch> [target-host] [args...]
  $0 [target-host] <build|test|boot|switch> [args...]
    A wrapper for nixos-rebuild.

    Operation is default to be `build` if omitted.
    Target host is default to be localhost if omitted.
    When only building remote configuration, drvs will not be copied to remote.
"
  exit 1
}

op=
target=
if [[ "$1" =~ ^(""|build|test|boot|switch)$ ]]; then
  op="${1:-build}"
  shift || true # Case of empty op.
  if [[ -n "$1" && "$1" != -* ]]; then
    target="$1"
    shift
  fi
elif [[ "$1" != -* && "$2" =~ ^(""|build|test|boot|switch)$ ]]; then
  target="$1"
  op="${2:-build}"
  shift
  shift || true # Case of empty op.
else
  echo "Invalid parameters: $*"
  exit 1
fi

args=()
if [[ -z "$target" && "$op" != "build" ]]; then
  args+=(sudo)
fi

args+=(nixos-rebuild "$op" --flake ".#${target:-$(hostname)}")
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
exec "${args[@]}"
