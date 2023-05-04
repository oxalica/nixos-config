# References:
# - https://github.com/ohmyzsh/ohmyzsh/blob/706b2f3765d41bee2853b17724888d1a3f6f00d9/lib/key-bindings.zsh
# - https://github.com/dramforever/config/blob/446e232cba4f3e05d83fb126516b1d9181fb7e67/home/zshrc
# - `/etc/zinputrc` from NixOS.
# - http://zsh.sourceforge.net/Doc/Release/Zsh-Line-Editor.html#Zle-Builtins
# - http://zsh.sourceforge.net/Doc/Release/Zsh-Line-Editor.html#Standard-Widgets

zmodload zsh/zle
zmodload zsh/terminfo

# Escape sequence timeout in 1/100s.
KEYTIMEOUT=1

# Make sure the terminal is in application mode, when zle is
# active. Only then are the values from $terminfo valid.
# From `/etc/zinputrc`.
if (( ${+terminfo[smkx]} && ${+terminfo[rmkx]} )); then
    zle-line-init() echoti smkx
    zle-line-finish() echoti rmkx
    zle -N zle-line-init
    zle -N zle-line-finish
fi

# Mode indicator.
zle-keymap-select() {
  RPS1=${KEYMAP/(main|viins)/}
  zle redisplay
}
zle -N zle-keymap-select

# Use viins key bindings
bindkey -v

bind() {
    [[ -z $1 ]] || bindkey $1 $2
}

# [Delete] - Delete forward
bind "${terminfo[kdch1]}" delete-char
# [Home]
bind "${terminfo[khome]}" beginning-of-line
# [End]
bind "${terminfo[kend]}" end-of-line
# [PageUp]
bind "${terminfo[kpp]}" beginning-of-buffer-or-history
# [PageDown]
bind "${terminfo[knp]}" end-of-buffer-or-history
# [Ctrl-RightArrow]
bind '^[[1;5C' forward-word
# [Ctrl-LeftArrow]
bind '^[[1;5D' backward-word


# [Left]
bind "${terminfo[kcub1]}" backward-char
# [Right]
bind "${terminfo[kcuf1]}" forward-char
# [Up]
bind "${terminfo[kcuu1]}" up-line-or-history
# [Down]
bind "${terminfo[kcud1]}" down-line-or-history

# [Shift-Tab]
bind "${terminfo[kcbt]}" reverse-menu-complete

autoload -U up-line-or-beginning-search
autoload -U down-line-or-beginning-search
zle -N up-line-or-beginning-search
zle -N down-line-or-beginning-search
# [Ctrl-p]
bind '^p' up-line-or-beginning-search
# [Ctrl-n]
bind '^n' down-line-or-beginning-search

# [Space]
bind ' ' magic-space

unfunction bind

preexec_load_history() {
    if [[ $1 == : ]]; then
        fc -RI
    fi
}
autoload -Uz add-zsh-hook
add-zsh-hook -Uz preexec preexec_load_history
