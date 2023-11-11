local node_symbol="\u2b22"

function node_prompt_version {
  if which node &> /dev/null; then
    echo "%{$fg_bold[blue]%}$node_symbol [%{$fg[green]%}$(node -v)%{$fg[blue]%}]%{$reset_color%}"
  fi
}

PROMPT='
%{$fg_bold[white]%}%~%{$fg_bold[blue]%}%{$fg_bold[blue]%} % %{$reset_color%}
%{$fg[green]%}➞  %{$reset_color%}'
RPROMPT='%{$bg[violet]%} $(node_prompt_version) $(git_prompt_info) %{$reset_color%}'

ZSH_THEME_GIT_PROMPT_PREFIX="%{$fg_bold[blue]%}[git:"
ZSH_THEME_GIT_PROMPT_SUFFIX="%{$reset_color%}"
ZSH_THEME_GIT_PROMPT_DIRTY="%{$fg[red]%} ⦿ %{$fg[blue]%}]%{$reset_color%}"
ZSH_THEME_GIT_PROMPT_CLEAN="%{$fg[green]%} ✔ %{$fg[blue]%}]%{$reset_color%}"