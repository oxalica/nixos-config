#!@runtimeShell@
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

if [[ "$action" =~ (boot|switch|test) && "$name" == "$localname" && "$(id -u)" != 0 ]]; then
    echo "'$action' expects root permission" >&2
    exit 1
fi

cmd=(nixos-rebuild "$action" --flake ".#$name" --keep-going)
if [[ "$name" != "$localname" && "$action" != *build* ]]; then
    cmd+=(
    --use-remote-sudo
    --target-host "$name"
    )
fi

cmd+=("$@")

set -x
exec "${cmd[@]}"
