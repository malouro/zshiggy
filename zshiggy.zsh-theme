#-------------------------
# Config variables

# Palette
ZSHIGGY_THEME_PRIMARY=${ZSHIGGY_THEME_PRIMARY:-blue}
ZSHIGGY_THEME_SECONDARY=${ZSHIGGY_THEME_SECONDARY:-magenta}

# Symbol before cursor in console
ZSHIGGY_SYMBOL=${ZSHIGGY_SYMBOL:-ϟ} # [⚡︎]

# Enable Git info prompt
ZSHIGGY_GIT_ENABLED=${ZSHIGGY_GIT_ENABLED:-true}
ZSHIGGY_GIT_SYMBOL=${ZSHIGGY_GIT_SYMBOL:-ᚿ}
ZSHIGGY_GIT_DIRTY_SYMBOL=${ZSHIGGY_GIT_DIRTY_SYMBOL:-•}
ZSHIGGY_GIT_CLEAN_SYMBOL=${ZSHIGGY_GIT_CLEAN_SYMBOL:-✔}

# Enable Node info prompt
ZSHIGGY_NODE_ENABLED=${ZSHIGGY_NODE_ENABLED:-true}
ZSHIGGY_NODE_SYMBOL=${ZSHIGGY_NODE_SYMBOL:-⬡}
ZSHIGGY_NODE_DIRTY_SYMBOL=${ZSHIGGY_NODE_DIRTY_SYMBOL:-•}
ZSHIGGY_NODE_CLEAN_SYMBOL=${ZSHIGGY_NODE_CLEAN_SYMBOL:-✔}

# ZSH theme vars; these should not be configured by user
ZSH_THEME_GIT_PROMPT_CLEAN="%{$reset_color%}%{$fg_bold[green]%}${ZSHIGGY_GIT_CLEAN_SYMBOL}"
ZSH_THEME_GIT_PROMPT_BEHIND="%{$fg[$ZSHIGGY_THEME_PRIMARY]%}↓%{$reset_color%}"
ZSH_THEME_GIT_PROMPT_AHEAD="%{$fg[$ZSHIGGY_THEME_PRIMARY]%}↑%{$reset_color%}"
ZSH_THEME_GIT_PROMPT_STAGED="%{$fg_bold[green]%}${ZSHIGGY_GIT_DIRTY_SYMBOL}%{$reset_color%}"
ZSH_THEME_GIT_PROMPT_UNSTAGED="%{$fg_bold[red]%}${ZSHIGGY_GIT_DIRTY_SYMBOL}%{$reset_color%}"
ZSH_THEME_GIT_PROMPT_UNTRACKED="%{$fg_bold[yellow]%}${ZSHIGGY_GIT_DIRTY_SYMBOL}%{$reset_color%}"


#-------------------------
# Utility function to make consistent "blocks" in the theme
# - Usage: $(make_block <"content">)
# - Output: "[<content>]" - with expected colors & styling
function make_block {
	args="$@"
	echo "%{$fg_no_bold[$ZSHIGGY_THEME_PRIMARY]%}[%{$fg_bold[$ZSHIGGY_THEME_SECONDARY]%}${args[@]}%{$fg_no_bold[$ZSHIGGY_THEME_PRIMARY]%}]%{$reset_color%}"
}

#-------------------------
# Node Info Display

# State of current directory being a potential Node project or not
local is_node_project=false

function zshiggy_check_if_node_project {
	if [[ -f "$PWD/package.json" && -r "$PWD/package.json" ]]; then
		is_node_project=true
	else
		is_node_project=false
	fi
}
function zshiggy_get_node_version {
	echo "$(node -v)"
}
# Usage: zshiggy_get_node_status <NODE_VERSION>
# If supplied NODE_VERSION doesn't match the local nvmrc version, prompt the user.
function zshiggy_get_node_status {
	local _node_version="$1"
	if [[ -f "$PWD/.nvmrc" && -r "$PWD/.nvmrc" ]]; then
		local _nvmrc_version="$(cat ./.nvmrc | tr -d " \t\n\r")"
		if [ "$(nvm version $_nvmrc_version)" = "$_node_version" ]; then
			echo "%{$fg_bold[green]%}${ZSHIGGY_NODE_CLEAN_SYMBOL}"
		else
			echo "%{$fg_bold[red]%}${ZSHIGGY_NODE_DIRTY_SYMBOL}"
		fi
	fi
}

autoload -U add-zsh-hooks

# Hook to check if new directory is a Node project
if [ "$ZSHIGGY_NODE_ENABLED" = "true" ]; then
	add-zsh-hook chpwd zshiggy_check_if_node_project;
	zshiggy_check_if_node_project;
fi

function zshiggy_node_prompt {
	if [ "$ZSHIGGY_NODE_ENABLED" = "false" ]; then
		return
	fi
	if [ "$is_node_project" = true ]; then
	if which node &> /dev/null; then
		local _ver="$(zshiggy_get_node_version)"
		local _node_symbol="%{$fg_no_bold[$ZSHIGGY_THEME_PRIMARY]%}${ZSHIGGY_NODE_SYMBOL}"
		local _node_version="%{$fg_bold[$ZSHIGGY_THEME_SECONDARY]%}$_ver"
		local _node_status="$(zshiggy_get_node_status $_ver)"

		echo $(make_block $_node_symbol:$_node_version$_node_status)
	fi
	fi
}

#-------------------------
# Git Info Display

function zshiggy_git_branch {
	_ref=$(command git symbolic-ref HEAD 2> /dev/null) || \
	_ref=$(command git rev-parse --short HEAD 2> /dev/null) || return
	echo "${_ref#refs/heads/}"
}

function zshiggy_git_status {
	local _ret_value=""
	local _git_status=""

	# Check status of local files
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
		if [ ! -z $_git_ahead_behind ]; then
			_git_ahead_behind="$_git_ahead_behind$_git_ahead_behind_separator"
		fi

		local git_behind_commits=$(echo $_git_status | \
		command grep -o '^## .*behind [0-9]*' | \
		command sed 's/\(^## .*behind \)//');
		_git_ahead_behind="$_git_ahead_behind$ZSH_THEME_GIT_PROMPT_BEHIND$git_behind_commits"
	fi

	_ret_value="$_ret_value$_git_ahead_behind"

	echo "$_ret_value%{$reset_color%}"
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

	local _symbol="%{$fg_no_bold[$ZSHIGGY_THEME_PRIMARY]%}${ZSHIGGY_GIT_SYMBOL}"
	local _branch_status="%{$fg_bold[$ZSHIGGY_THEME_SECONDARY]%}$_branch$(zshiggy_git_status)"

	# ie: "[ᚿ:main✔]"
	echo $(make_block $_symbol:$_branch_status)
}

#-------------------------
# Prompt!

PROMPT='
$(make_block %{$reset_color%}%~)
$(make_block ${ZSHIGGY_SYMBOL}) '
RPROMPT='$(zshiggy_node_prompt)$(zshiggy_git_prompt)'

