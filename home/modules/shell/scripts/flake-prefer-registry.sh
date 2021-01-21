#!@bash@/bin/bash
set -eo pipefail
PATH="@coreutils@/bin:@jq@/bin${PATH:+:}$PATH"

registries=( $(nix registry list | sed -nE 's/^\S+\s+flake:(\S+)\s.*$/\1/p' | sort | uniq) )
registries=" ${registries[*]} "
args=()
for name in $(nix eval --json -f ./flake.nix inputs | jq -r 'keys | .[]'); do
  if [[ "$registries" =~ " $name " ]]; then
    echo "Override $name"
    args+=(--override-input "$name" "$name")
  else
    echo "Free $name"
  fi
done

exec nix flake update "${args[@]}"
