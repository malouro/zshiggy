#-------------------------
# Config variables

# Theme colors
ZSHIGGY_THEME_PRIMARY="blue"
ZSHIGGY_THEME_SECONDARY="magenta"

# Symbol before cursor in console
ZSHIGGY_SYMBOL=${ZSHIGGY_SYMBOL:-ϟ} # ⚡︎

# Enable Git info prompt
ZSHIGGY_GIT_ENABLED=${ZSHIGGY_GIT_ENABLED:-true}
# Symbol to use for Git info
ZSHIGGY_GIT_SYMBOL=${ZSHIGGY_GIT_SYMBOL:-ᚿ}
# Symbol for Git dirty
ZSHIGGY_GIT_DIRTY_SYMBOL=${ZSHIGGY_GIT_DIRTY_SYMBOL:-⊙}
# Symbol for Git clean
ZSHIGGY_GIT_CLEAN_SYMBOL=${ZSHIGGY_GIT_CLEAN_SYMBOL:-✔}

# Enable Node info prompt
ZSHIGGY_NODE_ENABLED=${ZSHIGGY_NODE_ENABLED:-true}
# Symbol to use for Node info
ZSHIGGY_NODE_SYMBOL=${ZSHIGGY_NODE_SYMBOL:-⬡}


ZSH_THEME_GIT_PROMPT_CLEAN="%{$reset_color%}%{$fg_bold[green]%}${ZSHIGGY_GIT_CLEAN_SYMBOL}"
ZSH_THEME_GIT_PROMPT_BEHIND="%{$fg[blue]%}↓%{$reset_color%}"
ZSH_THEME_GIT_PROMPT_AHEAD="%{$fg[blue]%}↑%{$reset_color%}"
ZSH_THEME_GIT_PROMPT_UNSTAGED="%{$fg_bold[red]%}${ZSHIGGY_GIT_DIRTY_SYMBOL}%{$reset_color%}"
ZSH_THEME_GIT_PROMPT_UNTRACKED="%{$fg_bold[yellow]%}${ZSHIGGY_GIT_DIRTY_SYMBOL}%{$reset_color%}"

#-------------------------


#-------------------------
# Utility function to make consistent "blocks" in the theme
# - Usage: $(make_block <"content">)
# - Output: "[<content>]" - with expected colors & styling
function make_block {
	args="$@"
	echo "%{$fg[$ZSHIGGY_THEME_PRIMARY]%}[%{$fg_bold[$ZSHIGGY_THEME_SECONDARY]%}${args[@]}%{$reset_color%}%{$fg[$ZSHIGGY_THEME_PRIMARY]%}]"
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

function zshiggy_node_prompt {
	if [ "$ZSHIGGY_NODE_ENABLED" = "false" ]; then
		return
	fi
	if [ "$is_node_project" = true ]; then
	if which node &> /dev/null; then
		local _node_symbol="%{$fg[blue]%}${ZSHIGGY_NODE_SYMBOL}"
		local _node_version="%{$fg_bold[magenta]%}$(node -v)%{$fg[blue]%}"
		echo $(make_block %{$reset_color%}$_node_symbol:$_node_version)%{$reset_color%}
	fi
	fi
}

#-------------------------
# Git Info Display

function zshiggy_git_branch {
	ref=$(command git symbolic-ref HEAD 2> /dev/null) || \
	ref=$(command git rev-parse --short HEAD 2> /dev/null) || return
	echo "${ref#refs/heads/}"
}

function zshiggy_git_status {
	if [ "$ZSHIGGY_GIT_ENABLED" = "false" ]; then
		return;
	fi
	_ret_value=""

		# check status of files
	_git_status=$(command git status --porcelain 2> /dev/null)
	if [[ -n "$_git_status" ]]; then
		if $(echo "$_git_status" | command grep -q '^[AMRD]. '); then
			_ret_value="$_ret_value$ZSH_THEME_GIT_PROMPT_STAGED"
		fi
		if $(echo "$_git_status" | command grep -q '^.[MTD] '); then
			_ret_value="$_ret_value$ZSH_THEME_GIT_PROMPT_UNSTAGED"
		fi
		if $(echo "$_git_status" | command grep -q -E '^\?\? '); then
			_ret_value="$_ret_value$ZSH_THEME_GIT_PROMPT_UNTRACKED"
		fi
		if $(echo "$_git_status" | command grep -q '^UU '); then
			_ret_value="$_ret_value$ZSH_THEME_GIT_PROMPT_UNMERGED"
		fi
	else
		_ret_value="$_ret_value$ZSH_THEME_GIT_PROMPT_CLEAN"
	fi

	# check status of local repository
	_git_status=$(command git status --porcelain -b 2> /dev/null)
	if $(echo "$_git_status" | command grep -q '^## .*ahead'); then
		_ret_value="$_ret_value$ZSH_THEME_GIT_PROMPT_AHEAD"
	fi
	if $(echo "$_git_status" | command grep -q '^## .*behind'); then
		_ret_value="$_ret_value$ZSH_THEME_GIT_PROMPT_BEHIND"
	fi
	if $(echo "$_git_status" | command grep -q '^## .*diverged'); then
		_ret_value="$_ret_value$ZSH_THEME_GIT_PROMPT_DIVERGED"
	fi

	echo $_ret_value
}

function zshiggy_git_prompt {
	local _prompt="%{$reset_color%}%{$fg[blue]%}${ZSHIGGY_GIT_SYMBOL}:%{$fg_bold[magenta]%}$(zshiggy_git_branch)$(zshiggy_git_status)"
	echo $(make_block $_prompt)
}

#-------------------------
# Prompt!

PROMPT='
$(make_block %{$reset_color%}%{$fg[white]%}%~)%{$reset_color%}
$(make_block %{$fg_bold[magenta]%}${ZSHIGGY_SYMBOL}) %{$reset_color%}'
RPROMPT='$(zshiggy_node_prompt)$(zshiggy_git_prompt)%{$reset_color%}'

#-------------------------
