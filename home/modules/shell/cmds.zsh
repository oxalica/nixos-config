alias l="exa --classify"
alias ll="exa -l --classify --binary"
alias ls="exa"

alias n="nix"
alias nb="nix build"
alias nf="nix flake"
alias nr="nix repl"
alias nrp="nix repl '<nixpkgs>'"

alias g="git"
alias py="python"
alias rl="readlink"
alias rm="echo 'rm: You are WRONG.'"
alias t="bsdtar"

# List tree.
lt() {
  exa -T --classify --color=always $@ | eval $PAGER
}

# Clipboard input/output.
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

# Realpath of which.
rwhich() {
  which $@ | xargs realpath
}
