# -*- mode: sh; -*-
# Rivo prompt set-up

export __GIT_PROMPT_DIR=~/.zsh/git-prompt-python

# Allow for functions in the prompt
setopt prompt_subst 

# Enable auto-execution of functions
typeset -ga preexec_functions
typeset -ga precmd_functions
typeset -ga chpwd_functions

# Append git functions needed for prompts to various hooks
# Executed before each prompt
precmd_functions+='precmd_update_git_vars'
# Executed after a command has been read and is to be executed
preexec_functions+='preexec_update_git_vars'
# Executed after a directory change
chpwd_functions+='chpwd_update_git_vars'

# Append titlebar functions
precmd_functions+='precmd_titlebar'
preexec_functions+='preexec_titlebar'

# Load colors
autoload -U colors
colors

# Set some colors
local reset 
reset="%{${reset_color}%}"

for color in red green blue cyan  yellow magenta black white; do
    local $color b_$color
    eval $color='%{$fg[${color}]%}'
    eval b_$color='%{$fg_bold[${color}]%}'
done

# Colors for root and normal users
root_color=${red}
user_color=${green}

# Default values for the appearance of the prompt. Configure at will.
ZSH_THEME_GIT_PROMPT_PREFIX="("
ZSH_THEME_GIT_PROMPT_SUFFIX=")"
ZSH_THEME_GIT_PROMPT_SEPARATOR="|"
ZSH_THEME_GIT_PROMPT_BRANCH="${b_magenta}"
ZSH_THEME_GIT_PROMPT_STAGED="${red}●"
ZSH_THEME_GIT_PROMPT_CONFLICTS="${red}✖"
ZSH_THEME_GIT_PROMPT_CHANGED="${blue}✚"
ZSH_THEME_GIT_PROMPT_REMOTE=""
ZSH_THEME_GIT_PROMPT_UNTRACKED="${b_yellow}…"
ZSH_THEME_GIT_PROMPT_CLEAN="${b_green}✔"

function precmd {
PROMPT='%~%b$(git_super_status)
%# ${reset}'

RPROMPT='$(user_and_host)%t${reset}'
}

user_and_host() {
    local UH
    if [ "`id -u`" -eq 0 ] || [[ "$USER" = 'root' ]]; then
	UH="${root_color}%m" 
    else
        UH="${user_color}%n@%m"
    fi
    echo "$UH"
}

git_super_status() {
    precmd_update_git_vars
    local STATUS
    if [ -n "$__CURRENT_GIT_STATUS" ]; then
	STATUS="$ZSH_THEME_GIT_PROMPT_PREFIX$ZSH_THEME_GIT_PROMPT_BRANCH$GIT_BRANCH${reset}"
	if [ -n "$GIT_REMOTE" ]; then
	    STATUS="$STATUS$ZSH_THEME_GIT_PROMPT_REMOTE$GIT_REMOTE${reset}"
	fi
	STATUS="$STATUS$ZSH_THEME_GIT_PROMPT_SEPARATOR"
	if [ "$GIT_STAGED" -ne "0" ]; then
	    STATUS="$STATUS$ZSH_THEME_GIT_PROMPT_STAGED$GIT_STAGED${reset}"
	fi
	if [ "$GIT_CONFLICTS" -ne "0" ]; then
	    STATUS="$STATUS$ZSH_THEME_GIT_PROMPT_CONFLICTS$GIT_CONFLICTS${reset}"
	fi
	if [ "$GIT_CHANGED" -ne "0" ]; then
	    STATUS="$STATUS$ZSH_THEME_GIT_PROMPT_CHANGED$GIT_CHANGED${reset}"
	fi
	if [ "$GIT_UNTRACKED" -ne "0" ]; then
	    if [ "$GIT_UNTRACKED" -lt "10" ]; then
		STATUS="$STATUS${b_yellow}$GIT_UNTRACKED${reset}"
	    else
		STATUS="$STATUS$ZSH_THEME_GIT_PROMPT_UNTRACKED${reset}"
	    fi
	fi
	if [ "$GIT_CLEAN" -eq "1" ]; then
	    STATUS="$STATUS$ZSH_THEME_GIT_PROMPT_CLEAN"
	fi
	STATUS="$STATUS${reset}$ZSH_THEME_GIT_PROMPT_SUFFIX"
	echo "$STATUS"
    fi
}

#### Manage cache


function precmd_update_git_vars() {
    if [ -n "$__EXECUTED_GIT_COMMAND" ]; then
    	update_current_git_vars
        unset __EXECUTED_GIT_COMMAND
    fi
}

function preexec_update_git_vars() {
    case "$2" in
        git*)
        __EXECUTED_GIT_COMMAND=1
        ;;
    esac
}

function chpwd_update_git_vars() {
    update_current_git_vars
}

function update_current_git_vars() {
    unset __CURRENT_GIT_STATUS
    
    local gitstatus="$__GIT_PROMPT_DIR/gitstatus.py"
    _GIT_STATUS=`python ${gitstatus}`
    __CURRENT_GIT_STATUS=("${(@f)_GIT_STATUS}")
    GIT_BRANCH=$__CURRENT_GIT_STATUS[1]
    GIT_REMOTE=$__CURRENT_GIT_STATUS[2]
    GIT_STAGED=$__CURRENT_GIT_STATUS[3]
    GIT_CONFLICTS=$__CURRENT_GIT_STATUS[4]
    GIT_CHANGED=$__CURRENT_GIT_STATUS[5]
    GIT_UNTRACKED=$__CURRENT_GIT_STATUS[6]
    GIT_CLEAN=$__CURRENT_GIT_STATUS[7]
}

#### Manage titlebar
function precmd_titlebar(){
    titlebar "%~"
}

function preexec_titlebar(){
    titlebar $1
}

function titlebar() {
    [[ -t 1 ]] || return
    case $TERM in
	xterm*|rxvt*|(dt|k|E)term)
	    print -Pn "\e]0; %n@%M[%y] %# $1\a"
	    ;;
	screen)
	    print -Pn "\e]0;$1\a"
	    ;;
    esac
}

