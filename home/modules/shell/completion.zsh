# Modified from: https://github.com/ohmyzsh/ohmyzsh/blob/706b2f3765d41bee2853b17724888d1a3f6f00d9/lib/completion.zsh

ZSH_CACHE_DIR="${XDG_CACHE_HOME:-$HOME/.cache}/zsh"
ZSH_COMPDUMP="$ZSH_CACHE_DIR/zcompdump"
mkdir -p $ZSH_CACHE_DIR

# fixme - the load process here seems a bit bizarre
zmodload -i zsh/complist

WORDCHARS='*?_-.[]~=&;!#$%^(){}<>'  # remove '/'

unsetopt menu_complete   # do not autoselect the first completion entry
unsetopt flowcontrol
setopt auto_menu         # show completion menu on successive tab press
setopt complete_in_word
setopt always_to_end

# should this be in keybindings?
bindkey -M menuselect '^o' accept-and-infer-next-history
zstyle ':completion:*:*:*:*:*' menu select

# Don't try to expand multiple partial paths.
zstyle ':completion:*' path-completion false

# 1. Prefix completion.
# 2. Substring completion.
zstyle ':completion:*' matcher-list 'r:|=*' 'l:|=* r:|=*'

zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"

# Use caching so that commands like apt and dpkg complete are useable
zstyle ':completion:*' use-cache yes
zstyle ':completion:*' cache-path $ZSH_CACHE_DIR

# Completing indicator.
expand-or-complete-with-dots() {
  print -Pn "%F{blue}...%f"
  zle expand-or-complete
  zle redisplay
}
zle -N expand-or-complete-with-dots
bindkey '^I' expand-or-complete-with-dots

# Load bash completion functions.
autoload -U +X bashcompinit && bashcompinit

# Dump the current completion states.
() {
  local fpath_real=${fpath:P}
  local fpath_line="# fpath: ${fpath_real[*]}"
  local need_init=0

  if [[ "$(tail -n1 $ZSH_COMPDUMP 2>/dev/null)" != "$fpath_line" ]]; then
    need_init=1
    rm -f $ZSH_COMPDUMP
  fi

  autoload -U compinit
  compinit -u -C -d $ZSH_COMPDUMP

  if (( $need_init )); then
    printf '\n%s' $fpath_line >>$ZSH_COMPDUMP
  fi
}
