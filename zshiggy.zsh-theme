#-------------------------
# Config variables

# Palette
ZSHIGGY_THEME_PRIMARY="blue"
ZSHIGGY_THEME_SECONDARY="magenta"

# Symbol before cursor in console
ZSHIGGY_SYMBOL=${ZSHIGGY_SYMBOL:-ϟ} # ⚡︎

# Enable Git info prompt
ZSHIGGY_GIT_ENABLED=${ZSHIGGY_GIT_ENABLED:-true}
# Symbol to use for Git info
ZSHIGGY_GIT_SYMBOL=${ZSHIGGY_GIT_SYMBOL:-ᚿ}
# Symbol for Git dirty
ZSHIGGY_GIT_DIRTY_SYMBOL=${ZSHIGGY_GIT_DIRTY_SYMBOL:-•}
# Symbol for Git clean
ZSHIGGY_GIT_CLEAN_SYMBOL=${ZSHIGGY_GIT_CLEAN_SYMBOL:-✔}

# Enable Node info prompt
ZSHIGGY_NODE_ENABLED=${ZSHIGGY_NODE_ENABLED:-true}
# Symbol to use for Node info
ZSHIGGY_NODE_SYMBOL=${ZSHIGGY_NODE_SYMBOL:-⬡}

# ZSH theme vars
ZSH_THEME_GIT_PROMPT_CLEAN="%{$reset_color%}%{$fg_bold[green]%}${ZSHIGGY_GIT_CLEAN_SYMBOL}"
ZSH_THEME_GIT_PROMPT_BEHIND="%{$fg[$ZSHIGGY_THEME_PRIMARY]%}↓%{$reset_color%}"
ZSH_THEME_GIT_PROMPT_AHEAD="%{$fg[$ZSHIGGY_THEME_PRIMARY]%}↑%{$reset_color%}"
ZSH_THEME_GIT_PROMPT_STAGED="%{$fg_bold[green]%}${ZSHIGGY_GIT_DIRTY_SYMBOL}%{$reset_color%}"
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
		local _node_symbol="%{$fg[$ZSHIGGY_THEME_PRIMARY]%}${ZSHIGGY_NODE_SYMBOL}"
		local _node_version="%{$fg_bold[$ZSHIGGY_THEME_SECONDARY]%}$(node -v)%{$fg[blue]%}"
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
	local ret_value=""
	local _git_status=""

	# Check status of local files
	_git_status=$(command git status --porcelain 2> /dev/null)

	if [[ -n "$_git_status" ]]; then
		if $(echo "$_git_status" | command grep -q '^[AMRD]. '); then
			ret_value="$ret_value$ZSH_THEME_GIT_PROMPT_STAGED"
		fi
		if $(echo "$_git_status" | command grep -q '^.[MTD] '); then
			ret_value="$ret_value$ZSH_THEME_GIT_PROMPT_UNSTAGED"
		fi
		if $(echo "$_git_status" | command grep -q -E '^\?\? '); then
			ret_value="$ret_value$ZSH_THEME_GIT_PROMPT_UNTRACKED"
		fi
		if $(echo "$_git_status" | command grep -q '^UU '); then
			ret_value="$ret_value$ZSH_THEME_GIT_PROMPT_UNMERGED"
		fi
	else
		ret_value="$ret_value$ZSH_THEME_GIT_PROMPT_CLEAN"
	fi

	# Git commits ahead/behind
	_git_status=$(command git status --porcelain -b 2> /dev/null)
	_git_ahead_behind=""
	_git_ahead_behind_separator="%{$fg[$ZSHIGGY_THEME_PRIMARY]%}|%{$reset_color%}"

	if $(echo "$_git_status" | command grep -q '^## .*ahead'); then
		local git_ahead_commits=$(echo $_git_status | \
		command grep -o '^## .*ahead [0-9]*' | \
		command sed 's/\(^## .*ahead \)//');
		_git_ahead_behind="$_git_ahead_behind$ZSH_THEME_GIT_PROMPT_AHEAD$git_ahead_commits"
	fi
	if $(echo "$_git_status" | command grep -q '^## .*behind'); then
		if [ $_git_ahead_behind != "" ]; then
			_git_ahead_behind="$_git_ahead_behind$_git_ahead_behind_separator"
		fi

		local git_behind_commits=$(echo $_git_status | \
		command grep -o '^## .*behind [0-9]*' | \
		command sed 's/\(^## .*behind \)//');
		_git_ahead_behind="$_git_ahead_behind$ZSH_THEME_GIT_PROMPT_BEHIND$git_behind_commits"
	fi

	ret_value="$ret_value$_git_ahead_behind"

	echo "$ret_value%{$reset_color%}"
}

function zshiggy_git_prompt {
	if [ "$ZSHIGGY_GIT_ENABLED" = "false" ]; then
		return;
	fi

	local _branch=$(zshiggy_git_branch)

	# Not a git repo; or something is terribly wrong
	if [ "$_branch" = "" ]; then
		return;
	fi

	local _status=$(zshiggy_git_status)

	echo $(make_block %{$reset_color%}%{$fg[blue]%}${ZSHIGGY_GIT_SYMBOL}:%{$fg_bold[magenta]%}$_branch$_status)
}

#-------------------------
# Prompt!

PROMPT='
$(make_block %{$reset_color%}%{$fg[white]%}%~)%{$reset_color%}
$(make_block ${ZSHIGGY_SYMBOL}) %{$reset_color%}'
RPROMPT='$(zshiggy_node_prompt)$(zshiggy_git_prompt)%{$reset_color%}'

#-------------------------
