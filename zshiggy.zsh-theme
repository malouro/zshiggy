local node_symbol="\u2b22"
local is_node_project=false

check_if_node_project() {
  if [[ -f "$PWD/package.json" && -r "$PWD/package.json" ]]; then
    is_node_project=true
  else
    is_node_project=false
  fi
}

add-zsh-hook chpwd check_if_node_project
check_if_node_project

function node_prompt_version {
  if [ "$is_node_project" = true ]; then
  if which node &> /dev/null; then
    echo "%{$fg_bold[blue]%}[${node_symbol}:%{$fg[green]%}$(node -v)%{$fg[blue]%}]%{$reset_color%}"
  fi
  fi
}

ZSH_ZSHIGGY_SYMBOL="⚡"

PROMPT='
%{$fg_bold[white]%}%~%{$fg_bold[blue]%}%{$fg_bold[blue]%} % %{$reset_color%}
%{$reset_color%}${ZSH_ZSHIGGY_SYMBOL}  '
RPROMPT='$(node_prompt_version)$(git_prompt_info)%{$reset_color%}'


local git_behind_ahead_status_prefix="("
local git_behind_ahead_status_suffix=")"

function git_behind_ahead_status {
  local ret_value=""
  if [ "$(git_commits_behind)" -gt 0 ] | [ "$(git_commits_ahead)" -gt 0 ]; then
    ret_value="${git_behind_ahead_status_prefix}%{$fg[white]%}${$(git_commits_behind):-0}%{$fg[blue]%}↓ %{$fg[white]%}${$(git_commits_ahead):-0}%{$fg[blue]%}↑${git_behind_ahead_status_suffix}"
  fi
  echo $ret_value
}

ZSH_THEME_GIT_PROMPT_PREFIX=" %{$fg_bold[blue]%}[git:%{$fg[magenta]%}"
ZSH_THEME_GIT_PROMPT_SUFFIX="%{$reset_color%}"
ZSH_THEME_GIT_PROMPT_DIRTY="%{$fg[blue]%}]$(git_behind_ahead_status)%{$fg[red]%}⦿ %{$reset_color%}"
ZSH_THEME_GIT_PROMPT_CLEAN="%{$fg[blue]%}]$(git_behind_ahead_status)%{$fg[green]%}✔ %{$reset_color%}"
