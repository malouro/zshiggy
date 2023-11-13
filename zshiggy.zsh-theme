#!/usr/bin/env zsh

#-------------------------
# Config variables:
ZSHIGGY_PROMPT_SYMBOL="ϟ" # Symbol before cursor in console
ZSHIGGY_NODE_SYMBOL="⬡"   # Symbol in Node block


# Usage: $(make_block <"content">)
function make_block {
	args="$@"
	echo "%{$fg[blue]%}[%{$fg_bold[magenta]%}${args[@]}%{$reset_color%}%{$fg[blue]%}]"
}


# State of current directory being a potential Node project or not
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
		echo "%{$fg[blue]%}[${ZSHIGGY_NODE_SYMBOL}:%{$fg_bold[magenta]%}$(node -v)%{$reset_color%}%{$fg[blue]%}]%{$reset_color%}"
	fi
	fi
}


# Management of Git ahead/behind status
local git_behind_ahead_status_prefix="("
local git_behind_ahead_status_suffix=")"

# Looks like:
# <prefix><#behind>↓|<#ahead>↑<suffix>
# ie: "(0↓|1↑)"
function git_behind_ahead_status {
	local ret_value=""
	if [ "$(git_commits_behind)" -gt 0 ] | [ "$(git_commits_ahead)" -gt 0 ]; then
		ret_value="%{$fg[blue]%}${git_behind_ahead_status_prefix}%{$fg[white]%}${$(git_commits_behind):-0}%{$fg[blue]%}↓|%{$fg[white]%}${$(git_commits_ahead):-0}%{$fg[blue]%}↑${git_behind_ahead_status_suffix}%{$reset_color%}"
	fi
	echo $ret_value
}


PROMPT='
$(make_block %{$fg_bold[white]%}%~) %{$reset_color%}
$(make_block %{$fg_bold[magenta]%}${ZSHIGGY_PROMPT_SYMBOL}): %{$reset_color%}'
RPROMPT='$(node_prompt_version)$(git_prompt_info)%{$reset_color%}'


ZSH_THEME_GIT_PROMPT_PREFIX=" %{$fg_bold[blue]%}[git:%{$fg_bold[magenta]%}"
ZSH_THEME_GIT_PROMPT_SUFFIX="%{$reset_color%}%{$fg[blue]%}]%{$reset_color%}"
ZSH_THEME_GIT_PROMPT_DIRTY="%{$reset_color%}$(git_behind_ahead_status)%{$fg_bold[yellow]%}⦿"
ZSH_THEME_GIT_PROMPT_CLEAN="%{$reset_color%}$(git_behind_ahead_status)%{$fg_bold[green]%}●"
