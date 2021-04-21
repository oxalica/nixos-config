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
  if [[ "$XDG_SESSION_TYPE" == wayland ]]; then
    if [[ -t 0 ]]; then # stdin is tty, print clipboard
      wl-paste
    elif [[ -t 1 ]]; then # stdout is tty, put into clipboard
      wl-copy
    else
      echo "Cannot use '+' as pipe" >&2
      return 1
    fi
  else
    if [[ -t 0 ]]; then # stdin is tty, print clipboard
      xsel -ob
    elif [[ -t 1 ]]; then # stdout is tty, put into clipboard
      xsel -ib
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

# Binary diff
bdiff() {
    diff <(hexdump -C $1) <(hexdump -C $2) ${@:3}
}
