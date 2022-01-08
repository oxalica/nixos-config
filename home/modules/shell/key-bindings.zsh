# Modified from: https://github.com/ohmyzsh/ohmyzsh/blob/706b2f3765d41bee2853b17724888d1a3f6f00d9/lib/key-bindings.zsh

# http://zsh.sourceforge.net/Doc/Release/Zsh-Line-Editor.html
# http://zsh.sourceforge.net/Doc/Release/Zsh-Line-Editor.html#Zle-Builtins
# http://zsh.sourceforge.net/Doc/Release/Zsh-Line-Editor.html#Standard-Widgets

zmodload zsh/zle
zmodload zsh/terminfo

# Escape sequence timeout: 10ms
KEYTIMEOUT=1

# Make sure that the terminal is in application mode when zle is active, since
# only then values from $terminfo are valid
zle-line-init() {
  [[ -z ${terminfo[smkx]} ]] || echoti smkx
  RPS1=
  zle reset-prompt
}
zle-line-finish() {
  [[ -z ${terminfo[rmkx]} ]] || echoti rmkx
}
# Mode indicator.
zle-keymap-select() {
  RPS1=${KEYMAP/(main|viins)/}
  zle reset-prompt
}
zle -N zle-line-init
zle -N zle-line-finish
zle -N zle-keymap-select

# Use viins key bindings
bindkey -v

bindkey() { [[ -z $1 ]] || builtin bindkey $1 $2 }

# [Delete] - Delete forward
bindkey ${terminfo[kdch1]} delete-char
# [Home]
bindkey ${terminfo[khome]} beginning-of-line
# [End]
bindkey ${terminfo[kend]} end-of-line
# [PageUp]
bindkey ${terminfo[kpp]} up-line-or-history
# [PageDown]
bindkey ${terminfo[knp]} down-line-or-history
# [Ctrl-RightArrow]
bindkey '^[[1;5C' forward-word
# [Ctrl-LeftArrow]
bindkey '^[[1;5D' backward-word

# [Up]
bindkey ${terminfo[kcuu1]} up-line
# [Down]
bindkey ${terminfo[kcud1]} down-line

# [Shift-Tab]
bindkey ${terminfo[kcbt]} reverse-menu-complete

autoload -U up-line-or-beginning-search
zle -N up-line-or-beginning-search
autoload -U down-line-or-beginning-search
zle -N down-line-or-beginning-search
# [Ctrl-p]
bindkey '^p' up-line-or-beginning-search
# [Ctrl-n]
bindkey '^n' down-line-or-beginning-search

# [Ctrl-r] - Search backward incrementally for a specified string. The string may begin with ^ to anchor the search to the beginning of the line.
bindkey '^r' history-incremental-search-backward

# [Alt-m]
bindkey "^[m" copy-prev-shell-word

unfunction bindkey
