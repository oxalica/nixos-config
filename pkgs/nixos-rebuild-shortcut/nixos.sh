#!@runtimeShell@
set -eo pipefail
export PATH="$PATH${PATH:+:}"@paths@

localname="$(hostname)"
name="$localname"
action=build
if [[ "${1-}" == @* ]]; then
    name="${1:1}"
    shift
fi
if [[ "${1-}" = [^-]* ]]; then
    action="$1"
    shift
fi

# Simple local build.
if [[ "$action" == build && "$name" == "$localname" ]]; then
    set -x
    exec nom build .#nixosSystems."$name" "$@"
fi

cmd=(nixos-rebuild "$action" --flake ".#$name" --ask-sudo-password)
if [[ "$name" != "$localname" && "$action" != *build* ]]; then
    cmd+=( --target-host "$name" )
fi

cmd+=("$@")

echo "+ ${cmd[*]}"
"${cmd[@]}"

newVer="$(nix eval ".#nixosConfigurations.$name.config.system.build.kernel.version" --raw)"
curVer="$(uname --kernel-release)"
if [[ "$newVer" != "$curVer" ]]; then
    echo -e "\e[32;1mnote\e[0m: built kernel $newVer is different than the current $curVer"
fi
