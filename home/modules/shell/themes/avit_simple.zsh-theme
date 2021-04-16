# AVIT ZSH Theme Simplified

# settings
typeset +H _current_dir="%{$fg_bold[blue]%}%3~%{$reset_color%}"
typeset +H _return_status=" %{$fg_bold[red]%}%(?..[%?])%{$reset_color%}"
typeset +H _shell_level="%(2L. <%L>.)"

PROMPT='
$(_user_host)${_current_dir}$(_simple_git_prompt_info)${_shell_level}${_return_status}
%{%(!.${fg[red]}.${fg[white]})%}>%{$reset_color%} '

PROMPT2='%{%(!.${fg[red]}.${fg[white]})%}|%{$reset_color%} '

function _user_host() {
  local me
  if [[ -n $SSH_CONNECTION ]]; then
    me="%n@%m"
  elif [[ $LOGNAME != $USER ]]; then
    me="%n"
  fi
  if [[ -n $me ]]; then
    echo "%{$fg[cyan]%}$me%{$reset_color%}:"
  fi
}

_simple_git_prompt_info() {
  echo "${fg[green]}$(__git_ps1)%{$reset_color%}"
}

MODE_INDICATOR="%{$fg_bold[yellow]%}❮%{$reset_color%}%{$fg[yellow]%}❮❮%{$reset_color%}"
