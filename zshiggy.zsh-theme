#-------------------------
# Config variables

# Symbol before cursor in console
ZSHIGGY_PROMPT_SYMBOL=${ZSHIGGY_PROMPT_SYMBOL:-ϟ}
# Symbol to use for Git info
ZSHIGGY_GIT_SYMBOL=${ZSHIGGY_GIT_SYMBOL:-ᚿ}
# Enable Node info prompt
ZSHIGGY_NODE_ENABLED=${ZSHIGGY_NODE_ENABLED:-true}
# Symbol to use for Node info
ZSHIGGY_NODE_SYMBOL=${ZSHIGGY_NODE_SYMBOL:-⬡}


#-------------------------
# Utility function to make consistent "blocks" in the theme
# - Usage: $(make_block <"content">)
# - Output: "[<content>]" - with expected colors & styling
function make_block {
	args="$@"
	echo "%{$fg[blue]%}[%{$fg_bold[magenta]%}${args[@]}%{$reset_color%}%{$fg[blue]%}]"
}

#-------------------------
# Node Info Display

# State of current directory being a potential Node project or not
local is_node_project=false
function check_if_node_project {
	if [[ -f "$PWD/package.json" && -r "$PWD/package.json" ]]; then
		is_node_project=true
	else
		is_node_project=false
	fi
}

# Hook to check if new directory is a Node project
autoload -U add-zsh-hook
if [ "$ZSHIGGY_NODE_ENABLED" = "true" ]; then
	add-zsh-hook chpwd check_if_node_project;
	check_if_node_project;
fi

function node_prompt_info {
	if [ "$ZSHIGGY_NODE_ENABLED" = "false" ]; then
		return
	fi
	if [ "$is_node_project" = true ]; then
	if which node &> /dev/null; then
		echo "%{$fg[blue]%}[${ZSHIGGY_NODE_SYMBOL}:%{$fg_bold[magenta]%}$(node -v)%{$reset_color%}%{$fg[blue]%}]%{$reset_color%}"
	fi
	fi
}

#-------------------------
# Git ahead/behind Status
local git_behind_ahead_status_prefix="("
local git_behind_ahead_status_suffix=")"

# - Output:
#   <prefix><#behind>↓|<#ahead>↑<suffix>
#   ( ie: "(0↓|1↑)" )
function git_behind_ahead_status {
	local ret_value=""
	if [ "$(git_commits_behind)" -gt 0 ] | [ "$(git_commits_ahead)" -gt 0 ]; then
		ret_value="%{$fg[blue]%}${git_behind_ahead_status_prefix}%{$fg[white]%}${$(git_commits_behind):-0}%{$fg[blue]%}↓|%{$fg[white]%}${$(git_commits_ahead):-0}%{$fg[blue]%}↑${git_behind_ahead_status_suffix}%{$reset_color%}"
	fi
	echo $ret_value
}

#-------------------------
# Prompt!

PROMPT='
$(make_block %{$fg_bold[white]%}%~) %{$reset_color%}
$(make_block %{$fg_bold[magenta]%}${ZSHIGGY_PROMPT_SYMBOL}): %{$reset_color%}'
RPROMPT='$(node_prompt_info)$(git_prompt_info)%{$reset_color%}'


ZSH_THEME_GIT_PROMPT_PREFIX="%{$reset_color%}%{$fg[blue]%}[${ZSHIGGY_GIT_SYMBOL}:%{$fg_bold[magenta]%}"
ZSH_THEME_GIT_PROMPT_SUFFIX="%{$reset_color%}%{$fg[blue]%}]%{$reset_color%}"
ZSH_THEME_GIT_PROMPT_DIRTY="%{$reset_color%}$(git_behind_ahead_status)%{$fg_bold[yellow]%}⦿"
ZSH_THEME_GIT_PROMPT_CLEAN="%{$reset_color%}$(git_behind_ahead_status)%{$fg_bold[green]%}●"

#-------------------------
