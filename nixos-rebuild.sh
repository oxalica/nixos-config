#!/usr/bin/env bash
set -ex
exec nixos-rebuild --flake ".#$(hostname)" "$@"
