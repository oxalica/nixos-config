# AVIT ZSH Theme Simplified

setopt promptsubst

typeset +H _current_dir='%B%F{blue}%3~%f%b'
typeset +H _return_status=' %(?..%B%F{red}[%?]%f%b)'
typeset +H _shell_level='%(2L. <%L>.)'

PROMPT='
$(_user_host)${_current_dir}$(_git_info)${_shell_level}${_return_status}
%(!.%F{red}.%F{white})>%f '

PROMPT2='%(!.%F{red}.%F{white})|%f '

_user_host() {
  local me
  if [[ -n $SSH_CONNECTION ]]; then
    me="%n@%m"
  elif [[ $LOGNAME != $USER ]]; then
    me="%n"
  fi
  if [[ -n $me ]]; then
    echo -nE "%F{cyan}$me%f "
  fi
}

_git_info() {
  echo -nE "%F{green}$(__git_ps1)%f"
}
