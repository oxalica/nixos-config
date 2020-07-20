l() {
    exa --classify "$@"
}
ll() {
    exa -l --classify --binary --group --color=always "$@" | eval $PAGER
}
lt() {
    exa -T --classify --color=always "$@" | eval $PAGER
}

# Clipboard util
+() {
    if ! command -v xsel >/dev/null; then
        echo "'xsel' not found" >&2
        return 1
    elif [[ -t 0 ]]; then # stdin is tty, print clipboard
        xsel -ob
    elif [[ -t 1 ]]; then # stdout is tty, put into clipboard
        xsel -ib
    else
        echo "Cannot use '+' as pipe" >&2
        return 1
    fi
}
