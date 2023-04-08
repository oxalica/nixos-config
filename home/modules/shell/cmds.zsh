alias ls="exa"
alias l="exa --classify"
alias la="exa --classify -a"
alias ll="exa -l --classify --binary"
alias lla="exa -l --classify --binary -a"

alias n="nix"
alias nb="nix build"
alias nf="nix flake"
alias nr="nix repl"
alias nrp="nix repl -f '<nixpkgs>'"

alias v="nvim"
alias g="git"
alias py="python"
alias rl="readlink"
alias rp="realpath"
alias t="bsdtar"
alias hex="hexdump -C"
alias o="xdg-open"
alias reset="tput reset"

# List tree.
lt() {
    exa -T --classify --color=always $@ | eval $PAGER
}

# Clipboard input/output.
+() {
    local board
    if [[ "$XDG_SESSION_TYPE" == wayland ]]; then
        case $1 in
            p) board=--primary;;
            b|"") ;;
            *) echo "Invalid argument" >&2; return 1;;
        esac
        if [[ -t 0 ]]; then # stdin is tty, print clipboard
            wl-paste $board
        elif [[ -t 1 ]]; then # stdout is tty, put into clipboard
            wl-copy $board
        else
            echo "Cannot use '+' as pipe" >&2
            return 1
        fi
    else
        case $1 in
            p) board=--primary;;
            s) board=--secondary;;
            b|"") board=--clipboard;;
            *) echo "Invalid argument" >&2; return 1;;
        esac
        if [[ -t 0 ]]; then # stdin is tty, print clipboard
            xsel --output $board
        elif [[ -t 1 ]]; then # stdout is tty, put into clipboard
            xsel --input $board
        else
            echo "Cannot use '+' as pipe" >&2
            return 1
        fi
    fi
}

# Realpath of which.
rwhich() {
    command which $@ | xargs realpath
}

# Binary diff.
bdiff() {
    diff <(hexdump -C $1) <(hexdump -C $2) ${@:3}
}

# Length of stream, in human size.
len() {
    wc -c | numfmt --to=iec-i
}

# mkdir && cd
mkcd() {
    mkdir -p $1 && cd $1
}

# Run with limited memory.
limitmem() {
    (( $# < 3 )) && { echo "USAGE: limitmem <High> <Max> <cmds...>" >&2; return 1; }
    local cmd=(systemd-run --scope --user -p MemorySwapMax=0 -p MemoryHigh=$1 -p MemoryMax=$2 $argv[3,-1])
    echo -E "+ ${(q)cmd[@]}"
    ${cmd[@]}
}

# Patch interpreter to the dynamic linker.
patchinterp() {
    local interp glibc
    interp="$(patchelf --print-interpreter $1)" || return 1
    [[ $interp != /nix/store/* ]] || { echo "Already patched: $interp"; return 1; }
    linker="$(nix eval --raw nixpkgs#bintools.dynamicLinker)" && patchelf --set-interpreter $linker $1
}

closure() {
    nix path-info -Shr $@ | eval $PAGER
}
