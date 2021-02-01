#!/usr/bin/env -S bash -x
exec nix build '.#nixosConfigurations.iso.config.system.build.isoImage' "$@"
