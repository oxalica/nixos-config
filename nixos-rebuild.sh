#!/usr/bin/env bash
dir="$(dirname "${BASH_SOURCE[0]}")"
exec nixos-rebuild "$@" -I "oxa-config=$dir"
